'use server'
import { redirect } from 'next/navigation'
import { ContactSchema } from '@/validations/contact'

export async function submitContactForm(formData: FormData) {
  const name = formData.get('name');
  const email = formData.get('email');
  
  // バリデーション
  const validationResult = ContactSchema.safeParse({name, email});
  if(!validationResult.success) {
    const errors = validationResult.error.flatten();
    console.log('サーバー側でエラー', errors);
    return {};
  }

  // DB登録


  console.log('送信されたデータ: ', {name, email});
  redirect('/contacts/complete');
}
