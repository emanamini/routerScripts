**🌐 Languages:** 🇬🇧 [English](CaddySetup.md) • 🇮🇷 [فارسی](CaddySetup-FA.md)

---

### آماده‌سازی کَدی
ما برای اطمینان از عملکرد صحیح اپ، به گواهی `ssl` معتبر و دامنه متصل به کلاودفلر نیاز داریم. می‌توانید این بخش را نادیده بگیرید ولی یک دامنه ارزان یا حتی رایگان با قابلیت ویرایش رکوردهای دی‌ان‌اس ارزشش را دارد. در این آموزش، فرض بر این است که دامنه `ilola.ir` برای این کار در نظر گرفته شده. شما دامنهٔ خودتان را با آن در تنظیمات زیر عوض کنید. به کلاودفلر بروید و دامین خود را متصل کنید. در بخش [[#ساخت stamp شخصی]] توضیح مختصری در این زمینه داده بودم. 
در [صفحهٔ اصلی کلاودفلر](https://dash.cloudflare.com)، به منوی سمت چپ، بخش `Domains` و سپس `Overview` بروید. دامنهٔ خود را، که پیش‌تر اضافه کرده‌اید، انتخاب کنید. حالا باز از پنل سمت چپ `DNS` و سپس `Records` را انتخاب کنید. روی دکمه آبی `Add record` بزنید. `Type` را روی `A` قرار دهید. در فیلد `Name` کاراکتر `@` را قرار دهید. در `IPv4 address` هم آدرس آی‌پی `lan` خود، یعنی `172.22.0.1` را قرار دهید. تیک `Proxy Status` بایستی اتوماتیک خاموش شود. اگر نشد، خاموشش کنید. دو مرتبه روی دکمه آبی `Add record` بزنیدو مراحل قبل را تکرار کنید، با این تفاوت که در فیلد `Name` به جای `@` عبارت `www` را بنویسید و یک رکورد جدید بسازید. الان دو رکورد با آی‌پی `lan` داریم که یکی با آدرس ریشه و دیگری با آدرس `www` است. به سراغ تنظیمات بعدی کلاودفلر می‌رویم. به صفحه اصلی [داشبورد](https://dash.cloudflare.com) برگردید.

حالا برای دریافت توکن API به قسمت پایین نوار کناری با اسم `Manage account` بروید. سپس در منوی باز شده `Account API tokens` را انتخاب کنید. روی دکمه آبی `Create token` بزنید. در صفحه باز شده، زیر `Edit policy` منوی کشویی را باز کنید و آن را از`Entire account` به `Specified Domains` تغییر دهید. یک گزینه جلوی آن ظاهر می‌شود. دامنه‌ای که برای کَدی کنار گذاشتید را الان انتخاب کنید. در قسمت پایین‌تر `DNS & Zones` را باز کنید. تیک `Read` و `Edit` جلوی `DNS` و تیک `Read` جلوی `Zone` را بزنید. به پایین صفحه بروید و روی دکمه آبی `Review token` بزنید. در صفحه بعدی باید چیزی شبیه به این را ببینید:
```
ilola.ir in
e**********ni@gmail.com's Account

DNS Read
DNS Write
Zone Read
```
حالا روی دکمه آبی `Create token` بزنید.‌ یک کلید `API` برای شما صادر می‌شود. آن را همین الان در جای امنی ذخیره کنید چرا که فقط یک بار نمایش داده می‌شود. کلید، معمولا با عبارت `cfat` شروع می‌شود.

حالا باینری  کَدی `caddy` را برای سیستم از طریق این دستورات می‌گیریم و‌‌ به محل مورد نظر منتقل می‌کنیم
```
curl -sL "https://caddyserver.com/api/download?os=linux&arch=amd64&p=github.com%2Fcaddy-dns%2Fcloudflare" -o caddy

sudo mv caddy /usr/local/bin/caddy

sudo chmod +x /usr/local/bin/caddy

```
سپس سرویس کَدی را ویرایش می‌کنیم:
```
sudo systemctl edit caddy.service
```
دو خط در فایلی که باز می‌شود وجود دارد. یکی بالا و یکی کمی پایین‌تر:
```
### Anything between here and the comment below will become the contents of the drop-in file  
   
### Edits below this comment will be discarded
```
تنظیمات زیر، بایستی دقیقا بین این دو خط قرار بگیرند، وگرنه نادیده گرفته خواهند شد:
```
### Anything between here and the comment below will become the contents of the drop-in file  
  
[Unit]  
After=network-online.target arch-portal.service  
Wants=network-online.target arch-portal.service  
StartLimitIntervalSec=60s  
StartLimitBurst=10  
  
[Service]  
# 1. Clear and override the Validation pre-check  
ExecStartPre=  
ExecStartPre=/usr/local/bin/caddy validate --config /etc/caddy/Caddyfile  
  
# 2. Clear and override the Main startup command  
ExecStart=  
ExecStart=/usr/local/bin/caddy run --environ --config /etc/caddy/Caddyfile  
  
Restart=on-failure  
RestartSec=5s  
  
### Edits below this comment will be discarded
```
پیش‌نیاز این سرویس، [[#پورتال وی‌پی‌ان]] است که چند دقیقه دیگر سراغ ساختنش می‌رویم. حالا نوبت فایل کدی است.‌ با نانو بازش کنید:
```
sudo nano /etc/caddy/Caddyfile
```
مقادیر زیر مربوط به فایل من است. به آنها به چشم راهنما نگاه کنید. بایستی با توجه به متغیرهای خودتان آن را تغییر دهید:
```
{
    admin "unix//run/caddy/admin.socket"
}
# 1. The Real Domain (Uses Cloudflare DNS Challenge for valid SSL!)
ilola.ir, www.ilola.ir {
    tls {
        dns cloudflare cfat_XXXXXXXX
    }
    reverse_proxy 127.0.0.1:8080
}
# 2. Pure HTTP for the Fallback IPs
http://172.22.0.1 {
    reverse_proxy 127.0.0.1:8080
}
# 3. Forced HTTPS for the Fallback IPs
https://172.22.0.1 {
    tls internal
    reverse_proxy 127.0.0.1:8080
}
```
بایستی دو نام سایت و کلید `API` را با مقادیر مربوط به خودتان عوض کنید. با این تنظیمات، اینترفیس پورتال از طریق پورت ۸۰ روی آی‌پی `lan` در دسترس قرار می‌گیرد

اگر مراحل ثبت دامنه در کلاودفلر را انجام ندادید لازم است کل بلاک یک را با قرار دادن علامت `#` جلوی خطوطش تا `2#` کامنت کنید. در این صورت پورتال شما در حین اجرا خطای `ssl` می‌دهد و اجازه نصب به صورت یک برنامه مجزا را شاید به شما ندهد. خوبی خرید دامنه و اتصال آن به کلاودفلر و تنظیماتی که پیش‌تر گفتیم همین گرفتن خودکار گواهی معتبر `ssl` است. 

اگر کلاودفلر را تنظیم کرده‌اید نوبت `dnsmasq` به عنوان رابط بین آدرس دامنه و سرویس است. فایل کانفیگ آن را باز کنید و خط زیر را در بین تنظیمات قرار دهید:
```
sudo nano /etc/dnsmasq.conf
address=/ilola.ir/172.22.0.1
```
