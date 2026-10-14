import { firebaseMessaging } from '../../config/firebase';
import { PushTokensService } from '../push-tokens/push-tokens.service';

const pushTokensService = new PushTokensService();

export class PushDeliveryService {
  async sendToUser(params: {
    uid: string;
    title: string;
    body: string;
    data?: Record<string, string>;
  }) {
    if (!firebaseMessaging) {
      return;
    }

    const tokens = await pushTokensService.getTokensByUid(params.uid);
    if (tokens.length === 0) {
      return;
    }

    const response = await firebaseMessaging.sendEachForMulticast({
      tokens,
      notification: {
        title: params.title,
        body: params.body,
      },
      data: params.data,
      android: {
        priority: 'high',
        notification: {
          channelId: 'family_guard_high_importance',
        },
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
      },
    });

    const invalidTokens: string[] = [];
    response.responses.forEach((item, index) => {
      if (item.success) {
        return;
      }

      const errorCode = item.error?.code ?? '';
      if (
        errorCode.includes('registration-token-not-registered') ||
        errorCode.includes('invalid-registration-token')
      ) {
        invalidTokens.push(tokens[index]!);
      }
    });

    if (invalidTokens.length > 0) {
      await pushTokensService.deleteTokens(invalidTokens);
    }
  }
}
