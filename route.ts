import { NextResponse } from 'next/server';
export async function POST(req: Request) {
  try {
    const { question, context } = await req.json();
    if (!process.env.OPENAI_API_KEY) return NextResponse.json({ error: 'کلید هوش مصنوعی روی سرور تنظیم نشده است.' }, { status: 503 });
    const response = await fetch('https://api.openai.com/v1/responses', {
      method: 'POST',
      headers: { 'Content-Type':'application/json', 'Authorization':`Bearer ${process.env.OPENAI_API_KEY}` },
      body: JSON.stringify({
        model: 'gpt-4.1-mini',
        input: [
          { role:'system', content:'تو دستیار تحلیل مالی داخلی شرکت تبلیغاتی 3baz هستی. فقط بر اساس داده‌های ارائه‌شده تحلیل کن، عدد یا رویداد مالی نساز، همه مبالغ را تومان فرض کن. این گزارش‌ها مدیریتی‌اند و مشاوره مالیاتی قطعی نیستند. پاسخ فارسی و مختصر بده.' },
          { role:'user', content:`داده‌های مالی ثبت‌شده:\n${JSON.stringify(context).slice(0,18000)}\n\nپرسش: ${String(question).slice(0,1500)}` }
        ],
        max_output_tokens: 700
      })
    });
    const data = await response.json();
    if (!response.ok) return NextResponse.json({ error: data?.error?.message || 'خطا در سرویس هوش مصنوعی' }, { status: 502 });
    const answer = (data.output || []).flatMap((item:any)=>item.content||[]).filter((x:any)=>x.type==='output_text').map((x:any)=>x.text).join('\n');
    return NextResponse.json({ answer: answer || 'پاسخی دریافت نشد.' });
  } catch {
    return NextResponse.json({ error:'در پردازش درخواست خطایی رخ داد.' }, { status:500 });
  }
}
