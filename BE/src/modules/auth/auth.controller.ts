import { Request, Response } from 'express';
import { AuthService } from './auth.service';
import { loginSchema, registerSchema } from './auth.validation';

const authService = new AuthService();

export class AuthController {
  async register(req: Request, res: Response) {
    try {
      const parsed = registerSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          message: 'Dữ liệu đăng ký không hợp lệ',
          errors: parsed.error.flatten(),
        });
      }

      const data = await authService.register(parsed.data);

      return res.status(201).json({
        message: 'Đăng ký tài khoản thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error?.message || 'Đăng ký thất bại',
      });
    }
  }
  async login(req: Request, res: Response) {
    try {
      const parsed = loginSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          message: 'Dữ liệu không hợp lệ',
          errors: parsed.error.flatten(),
        });
      }

      const data = await authService.login(
        parsed.data.email,
        parsed.data.password,
      );

      return res.status(200).json({
        message: 'Đăng nhập thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error?.message || 'Đăng nhập thất bại',
      });
    }
  }

  async logout(req: Request, res: Response) {
    try {
      const authHeader = req.headers.authorization;

      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({
          message: 'Thiếu access token',
        });
      }

      const accessToken = authHeader.replace('Bearer ', '').trim();

      const data = await authService.logout(accessToken);

      return res.status(200).json({
        message: 'Đăng xuất thành công',
        data,
      });
    } catch (error: any) {
      return res.status(400).json({
        message: error?.message || 'Đăng xuất thất bại',
      });
    }
  }

  async me(req: Request, res: Response) {
    try {
      if (!req.userId) {
        return res.status(401).json({
          message: 'Người dùng chưa được xác thực',
        });
      }

      const data = await authService.me(req.userId);

      return res.status(200).json({
        message: 'Lấy thông tin thành công',
        data,
      });
    } catch (error: any) {
      return res.status(500).json({
        message: error?.message || 'Không lấy được thông tin người dùng',
      });
    }
  }
}