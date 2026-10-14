import { Request, Response, NextFunction } from 'express';
import { supabaseAdmin } from '../config/supabase';

export async function authMiddleware(
  req: Request,
  res: Response,
  next: NextFunction,
) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Thiếu access token' });
    }

    const token = authHeader.replace('Bearer ', '').trim();

    const {
      data: { user },
      error,
    } = await supabaseAdmin.auth.getUser(token);

    if (error || !user) {
      return res.status(401).json({ message: 'Token không hợp lệ' });
    }

    req.userId = user.id;
    req.accessToken = token;
    next();
  } catch (error) {
    return res.status(500).json({ message: 'Lỗi xác thực', error });
  }
}