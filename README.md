# SSH TUI Panel
A simple Text User-Interface to manage and monitor ssh users.

## Installation
```bash
sudo rm -f ssh-panel-install.sh && wget -O ssh-panel-install.sh https://raw.githubusercontent.com/vfarid/ssh-panel/main/install.sh && sudo sh ssh-panel-install.sh && sudo rm -f ssh-panel-install.sh
```

دستور بالا را کپی کرده و پس از لاگین روی ترمینال سرور بر روی مسیر دلخواه (ترجیحا در همان مسیر پیش فرض) اجرا کنید.
پس از اتمام نصب، یک فولدر به نام ssh-panel ایجاد گردیده و شما به داخل فولدر هدایت شده اید.

```bash
cd ssh-panel && sh panel.sh
```

با اجرای دستور بالا، پنل را فعال کرده و با استفاده از گزینه‌های موجود می توانید:
 - ترافیک مصرفی هر کاربر را مشاهده کنید
 - کاربران موجود را مدیریت کنید (شامل حذف/غیرفعال/تغییر رمز/مشاهده مصرف)
 - کاربر جدید ایجاد کنید
 - در بین کاربران جستجو کنید

ترافیک کاربران در پس زمینه ثبت می شود و پنل تنها برای مشاهده و مدیریت می باشد. پس از اتمام کار با انتخاب گزینه‌ی Exit از پنل خارج شوید.
