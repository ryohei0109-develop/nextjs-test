import { z } from 'zod'

export const ContactSchema = z.object({
  name: z.string()
    .min(3, '名前は3文字以上で入力して下さい。')
    .max(20, '名前は20文字以内で入力して下さい。'),
  email: z.string()
    .min(1, 'メールアドレスは必須です。')
    .email('正しいメールアドレスの形式で入力して下さい。')
});

// 型の定義
export type ContactType = z.infer<typeof ContactSchema>;
