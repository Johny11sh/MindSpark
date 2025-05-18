// ignore_for_file: unused_import, file_names

import 'package:get/get.dart';

class Locale implements Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    "En": {
      "Sign Up": "Sign Up",
      "Log In": "Log In",
      "Already have an account?": "Already have an account?",
      "User Name": "User Name",
      "Please enter your User Name": "Please enter your User Name",
      "User Name must be longer than 3 characters":
          "User Name must be longer than 3 characters",
      "User Name must be shorter than 20 characters":
          "User Name must be shorter than 20 characters",
      "Number": "Number",
      "Please enter your Phone Number": "Please enter your Phone Number",
      "Phone Number must be : 09XXXXXXXX": "Phone Number must be : 09XXXXXXXX",
      "Phone Number must be 10 digits": "Phone Number must be 10 digits",
      "Phone Number must ONLY contain numbers":
          "Phone Number must ONLY contain numbers",
      "Password": "Password",
      "Please enter your password": "Please enter your password",
      "Password must be at least 8 characters":
          "Password must be at least 8 characters",
      "Confirm Password": "Confirm Password",
      "Passwords do not match": "Passwords do not match",
      "You don't have an account?": "You don't have an account?",
      "Your personal collection for your favorite subjects' lectures, that include videos filmed by the teachers themselves that are comprehensive of your learning process, guaranteeing progress and utter improvement.":
          "Your personal collection for your favorite subjects' lectures, that include videos filmed by the teachers themselves and PDF files that are comprehensive of your learning process, guaranteeing progress and utter improvement.",
      "Listen and watch as the teachers guide you in a comprehensive step-by-step journey for the subjects of your picking.":
          "Listen and watch as the teachers guide you in a comprehensive step-by-step journey for the subjects of your picking.",
      "Improve on your cognitive and creative abilities with the help of this compact yet simple app, each lecture right at your fingertips and at-the-ready, even when offline.":
          "Improve on your cognitive and creative abilities with the help of this compact yet simple app, each lecture right at your fingertips and at-the-ready, even when offline.",
      "Change Username": "Change Username",
      "Change Password": "Change Password",
      "Language": "Language",
      "Theme": "Theme",
      "About Us": "About Us",
      "Contact Us": "Contact Us",
      "Privacy Policy": "Privacy Policy",
      "Log Out": "Log Out",
      "Settings": "Settings",
      "Teachers": "Teachers",
      "Home Page": "Home Page",
      "Profile": "Profile",
      "Choose a lecture": "Choose a lecture",
      "Choose a subject": "Choose a subject",
      "Choose a teacher": "Choose a teacher",
      "Choose a university": "Choose a university",
      "Teacher Profile": "Teacher Profile",
      "Damascus University": "Damascus University",
      "Aleppo University": "Aleppo University",
      "Tishreen University": "Tishreen University",
      "Home": "Home",
      "lecture": "lecture",
      "Subjects": "Subjects",
      "Usernames do not match": "Usernames do not match",
      "Light mode": "Light mode",
      "Choose application's theme mode": "Choose application's theme mode",
      "Choose application's language": "Choose application's language",
      "English": "English",
      "Arabic": "Arabic",
      "German": "German",
      "Turkish": "Turkish",
      "Error": "Error",
      "Failed to check connectivity:": "Failed to check connectivity:",
      "Please connect to the internet or you will have limited features":
          "Please connect to the internet or you will have limited features",
      "Internet connection restored": "Internet connection restored",
      "Old Password": "Old Password",
      "New Password": "New Password",
      "Please enter a New Password": "Please enter a New Password",
      "Please enter your OLD Password": "Please enter your OLD Password",
      "Please confirm your new password": "Please confirm your new password",
      "No internet connection": "No internet connection",
      "Confirm": "Confirm",
      "Confirm User Name": "Confirm User Name",
      "Please confirm your Username": "Please confirm your Username",
      "Language code cannot be empty": "Language code cannot be empty",
      "Unsupported language code:": "Unsupported language code:",
      "Log In failed": "Log In failed",
      "Get Started": "Get Started",
      "Continue": "Continue",
      "Please enter A User Name": "Please enter A User Name",
      "Please enter A Password": "Please enter A Password",
      "Sign Up failed": "Sign Up failed",
      "Video Player": "Video Player",
      "failed to change the username": "failed to change the username",
      "failed to change the password": "failed to change the password",
      "● Subjects:": "● Subjects:",
      "● Universities:": "● Universities:",
      "Select Video Quality": "Select Video Quality",
      "Don't have an account?": "Don't have an account?",
      "Log In failed, fill the textfields correctly":
          "Log In failed, fill the textfields correctly",
      "Validation Error": "Validation Error",
      "Username and password are required":
          "Username and password are required",
      "Invalid Credentials": "Invalid Credentials",
      "Please check your username and password":
          "Please check your username and password",
      "Unknown error occurred": "Unknown error occurred",
      "Network Error": "Network Error",
      "Timeout": "Timeout",
      "Invalid server response": "Invalid server response",
      "The request took too long. Please try again.":
          "The request took too long. Please try again.",
      "An unexpected error occurred": "An unexpected error occurred",
      "Sign up failed, fill the textfields correctly":
          "Sign up failed, fill the textfields correctly",
      "Request timeout. Please try again.":
          "Request timeout. Please try again.",
      "Number is already taken": "Number is already taken",
      "Username is already taken": "Username is already taken",
      "Username and number are already taken":
          "Username and number are already taken",
      "All fields are required": "All fields are required",
      "Session expired. Please log in again.":
          "Session expired. Please log in again.",
      "Both old and new passwords are required":
          "Both old and new passwords are required",
      "Password changed successfully": "Password changed successfully",
      "Invalid old password": "Invalid old password",
      "Invalid request": "Invalid request",
      "Network error. Please check your connection.":
          "Network error. Please check your connection.",
      "Username cannot be empty": "Username cannot be empty",
      "Username must be at least 3 characters":
          "Username must be at least 3 characters",
      "Username changed successfully": "Username changed successfully",
      "Username already taken": "Username already taken",
      "Local session cleared": "Local session cleared",
      "Choose a teacher for more details": "Choose a teacher for more details",
      "1. Information We Collect": "1. Information We Collect",
      "When you register, we collect the following:\n- Username: (to identify your account).\n- Password: (stored securely in hashed form for authentication).\n- Phone Number: (used for account identification and subscription management).":
          "When you register, we collect the following:\n- Username: (to identify your account).\n- Password: (stored securely in hashed form for authentication).\n- Phone Number: (used for account identification and subscription management).",
      "2. How We Use Your Information": "2. How We Use Your Information",
      "3. Data Storage & Security": "3. Data Storage & Security",
      "- Your password is hashed (encrypted) and cannot be accessed even by administrators.\n- Phone numbers and usernames are stored securely in our database.\n- Only authorized administrators can access user data for management purposes.":
          "- Your password is hashed (encrypted) and cannot be accessed even by administrators.\n- Phone numbers and usernames are stored securely in our database.\n- Only authorized administrators can access user data for management purposes.",
      "4. No Third-Party Sharing": "4. No Third-Party Sharing",
      "5. Your Rights": "5. Your Rights",
      "- You can request to:\n- View the personal data we store (username/phone number).\n- Update or delete your account (subject to admin approval).\n- Since passwords are hashed, they cannot be retrieved—only reset.":
          "- You can request to:\n- View the personal data we store (username/phone number).\n- Update or delete your account (subject to admin approval).\n- Since passwords are hashed, they cannot be retrieved—only reset.",
      "8. Changes to This Policy": "8. Changes to This Policy",
      "Updates will be posted here with a new \"Last Updated\" date.":
          "Updates will be posted here with a new \"Last Updated\" date.",
      "Welcome to Everything App!": "Welcome to Everything App!",
      "The purpose of this app is to \"save effort, time, and costs\" (such as lecture halls and transportation expenses). All our courses will be available in this app as \"well-organized and beautifully structured videos\".":
          "The purpose of this app is to \"save effort, time, and costs\" (such as lecture halls and transportation expenses). All our courses will be available in this app as \"well-organized and beautifully structured videos\".",
      "- Username & Password: Used solely for login authentication.\n- Phone Number: Displayed on your profile and used by administrators to manage subscriptions.\n- We do not use your data for marketing, analytics, or third-party sharing.":
          "- Username & Password: Used solely for login authentication.\n- Phone Number: Displayed on your profile and used by administrators to manage subscriptions.\n- We do not use your data for marketing, analytics, or third-party sharing.",
      "- We do not share your data with advertisers, Google, Facebook, or any external services.\n- No automated sign-in (e.g., Google/Facebook login) is used.":
          "- We do not share your data with advertisers, Google, Facebook, or any external services.\n- No automated sign-in (e.g., Google/Facebook login) is used.",
      "6. Account Usage & Device Restrictions":
          "6. Account Usage & Device Restrictions",
      "- Each account can only be used on one device at a time.\n- If you switch devices, you must contact our team to delete the old account before signing up again.\n- Subscriptions tied to your old account will be manually reinstated by our team after verification.":
          "- Each account can only be used on one device at a time.\n- If you switch devices, you must contact our team to delete the old account before signing up again.\n- Subscriptions tied to your old account will be manually reinstated by our team after verification.",
      "7. Data Retention": "7. Data Retention",
      "- When you request an account deletion (to migrate to a new device), your phone number, username, and subscription data may be retained temporarily to facilitate manual recovery.\n- Fully deleted accounts are irrecoverable unless you re-register and contact support.":
          "- When you request an account deletion (to migrate to a new device), your phone number, username, and subscription data may be retained temporarily to facilitate manual recovery.\n- Fully deleted accounts are irrecoverable unless you re-register and contact support.",
      "Light Mode": "Light Mode",
      "Dark Mode": "Dark Mode",
      "Telegram Group:": "Telegram Group:",
      "WhatsApp support:": "WhatsApp support:",
      "Announcements:": "Announcements:",
      "Connection error": "Connection error",
      "Connection access is needed": "Connection access is needed",
      "Subject not subscribed.": "Subject not subscribed.",
      "Not subscribed!": "Not subscribed!",
      "You need to purchase the whole subject or this particular lecture in order to download it.":
          "You need to purchase the whole subject or this particular lecture in order to download it.",
      "Storage and network access are needed":
          "Storage and network access are needed",
      "Contact the support team for instructions on how to subscribe to the lecture/subject first.":
          "Contact the support team for instructions on how to subscribe to the lecture/subject first.",
      "OK": "OK",
      "Problem fetching the lecture": "Problem fetching the lecture",
      "Could not connect to the server. Please check your connection.":
          "Could not connect to the server. Please check your connection.",
      "Warning!": "Warning!",
      "Taking Screenshots can cause a ban on your account.":
          "Taking Screenshots can cause a ban on your account.",
      "Recording videos can cause a ban on your account.":
          "Recording videos can cause a ban on your account.",
      "Banned Account!": "Banned Account!",
      "Contact the support team to restore this account.":
          "Contact the support team to restore this account.",
      "Old password is not correct": "Old password is not correct",
      "Password changing failed": "Password changing failed",
      "Username changing failed": "Username changing failed",
      "his username is already taken": "his username is already taken",
      "Failed to load video: this quality is not available":
          "Failed to load video: this quality is not available",
      "Support team": "Support team",
      "WhatsApp": "WhatsApp",
      "Telegram": "Telegram",
      "Username": "Username",
      "09XXXXXXXX": "09XXXXXXXX",
      "● Subscriptions:\n": "● Subscriptions:\n",
      "\n● Lectures number: X": "\n● Lectures number: X",
      "Contact the support team for instructions on how to subscribe to the lecture/subject first.'":
          "Contact the support team for instructions on how to subscribe to the lecture/subject first.'",
      "● Number:": "● Number:",
      "360p": "360p",
      "720p": "720p",
      "1080p": "1080p",
      "Auto": "Auto",
      "Failed to load video": "Failed to load video",
      "Retry": "Retry",
      "Screen capture detected. This may lead to account suspension.":
          "Screen capture detected. This may lead to account suspension.",
      "Screen recording detected!": "Screen recording detected!",
      "Screenshot detected!": "Screenshot detected!",
      "Connected to the internet": "Connected to the internet",
      "This username is already taken": "This username is already taken",
      "Username changing failed, connection access is needed":
          "Username changing failed, connection access is needed",
      "Support team:": "Support team:",
      "Choose a major": "Choose a major",
      "● Majors:": "● Majors:",
    },

    "Ar": {
      "Sign Up": "إنشاء حساب",
      "Log In": "تسجيل الدخول",
      "Already have an account?": "لديك حساب بالفعل مسبقاً؟",
      "User Name": "اسم المستخدم",
      "Please enter your User Name": "أدخل اسمك رجاءاً",
      "User Name must be longer than 3 characters":
          "اسم المستخدم يجب أن يكون أطول من ٣ أحرف",
      "User Name must be shorter than 20 characters":
          "اسم المستخدم يجب أن يكون أقصر من ٢٠ أحرف",
      "Number": "رقم الهاتف",
      "Please enter your Phone Number": "أدخل رقم الهاتف الخاص بك رجاءاً",
      "Phone Number must be : 09XXXXXXXX":
          ": ٠٩xxxxxxxx رقم الهاتف يجب أن يكون على النمط ",
      "Phone Number must be 10 digits":
          "رقم الهاتف يجب أن يكون مؤلفاً من ١٠ أرقام",
      "Phone Number must ONLY contain numbers":
          "رقم الهاتف يجب أن يحوي أرقاماً فقط",
      "Password": "كلمة السر",
      "Please enter your password": "أدخل كلمة سر رجاءاً",
      "Password must be at least 8 characters":
          "كلمة السر يجب أن تكون أطول من ٨ أحرف",
      "Confirm Password": "تأكيد كلمة السر",
      "Passwords do not match": "كلمتي السر غير متشابهتان",
      "You don't have an account?": "ليس لديك حساب مسبقاً",
      "Your personal collection for your favorite subjects' lectures, that include videos filmed by the teachers themselves and PDF files that are comprehensive of your learning process, guaranteeing progress and utter improvement.":
          "مجموعتك الشخصية لمحاضرات موادك المفضلة، والتي تشمل فيديوهات تم تصويرها بواسطة المعلمين أنفسهم وملفات PDF شاملة لعملية تعلمك، مما يضمن التقدم والتحسن الكامل.",
      "Listen and watch as the teachers guide you in a comprehensive step-by-step journey for the subjects of your picking.":
          "استمع وشاهد بينما يقوم المعلمون بإرشادك في رحلة شاملة خطوة بخطوة لموادك المفضلة.",
      "Improve on your cognitive and creative abilities with the help of this compact yet simple app, each lecture right at your fingertips and at-the-ready, even when offline.":
          "طور قدراتك المعرفية والإبداعية بمساعدة هذا التطبيق البسيط والمركز، حيث تكون كل محاضرة في متناول يديك وجاهزة للاستخدام، حتى بدون اتصال بالإنترنت.",
      "Change Username": "تغيير الاسم",
      "Change Password": "تغيير كلمة المرور",
      "Language": "اللغة",
      "Theme": "المظهر",
      "About Us": "معلومات عنا",
      "Contact Us": "تواصَل معنا",
      "Privacy Policy": "سياسة الأمان",
      "Log Out": "تسجيل الخروج",
      "Settings": "اللإعدادات",
      "Teachers": "الأساتذة",
      "Home Page": "الصفحة الرئيسية",
      "Profile": "الصفحة الشخصية",
      "Choose a lecture": "اختر محاضرة",
      "Choose a subject": "اختر مادة",
      "Choose a teacher": "اختر أستاذ",
      "Choose a university": "اختر جامعة",
      "Teacher Profile": "ملف الأستاذ",
      "Damascus University": "جامعة دمشق",
      "Aleppo University": "جامعة حلب",
      "Tishreen University": "جامعة تشرين",
      "Home": "الرئيسية",
      "lecture": "محاضرة",
      "Subjects": "المواد",
      "Usernames do not match": "أسماء المستخدمين غير متطابقة",
      "Light mode": "الوضع الفاتح",
      "Choose application's theme mode": "اختر نمط التطبيق",
      "Choose application's language": "اختر لغة التطبيق",
      "English": "الإنجليزية",
      "Arabic": "العربية",
      "German": "الألمانية",
      "Turkish": "التركية",
      "Error": "خطأ",
      "Failed to check connectivity:": "فشل التحقق من الاتصال:",
      "Please connect to the internet or you will have limited features":
          "يرجى الاتصال بالإنترنت وإلا ستكون الميزات محدودة",
      "Internet connection restored": "تم استعادة الاتصال بالإنترنت",
      "Old Password": "كلمة السر القديمة",
      "New Password": "كلمة السر الجديدة",
      "Please enter a New Password": "الرجاء إدخال كلمة سر جديدة",
      "Please enter your OLD Password": "الرجاء إدخال كلمة السر القديمة",
      "Please confirm your new password": "الرجاء تأكيد كلمة السر الجديدة",
      "No internet connection": "لا يوجد اتصال بالإنترنت",
      "Confirm": "تأكيد",
      "Confirm User Name": "تأكيد اسم المستخدم",
      "Please confirm your Username": "الرجاء تأكيد اسم المستخدم",
      "Language code cannot be empty": "رمز اللغة لا يمكن أن يكون فارغًا",
      "Unsupported language code:": "رمز اللغة غير مدعوم:",
      "Log In failed": "فشل تسجيل الدخول",
      "Get Started": "ابدأ الآن",
      "Continue": "متابعة",
      "Please enter A User Name": "الرجاء إدخال اسم مستخدم",
      "Please enter A Password": "الرجاء إدخال كلمة سر",
      "Sign Up failed": "فشل التسجيل",
      "Video Player": "مشغل الفيديو",
      "failed to change the username": "فشل تغيير اسم المستخدم",
      "failed to change the password": "فشل تغيير كلمة السر",
      "● Subjects:": "● المواد:",
      "● Universities:": "● الجامعات:",
      "Select Video Quality": "اختر جودة الفيديو",
      "Don't have an account?": "ليس لديك حساب؟",
      "Log In failed, fill the textfields correctly":
          "فشل تسجيل الدخول، يرجى ملء الحقول بشكل صحيح",
      "Validation Error": "خطأ في التحقق",
      "Username and password are required": "اسم المستخدم وكلمة السر مطلوبان",
      "Invalid Credentials": "بيانات الاعتماد غير صالحة",
      "Please check your username and password":
          "يرجى التحقق من اسم المستخدم وكلمة السر",
      "Unknown error occurred": "حدث خطأ غير معروف",
      "Network Error": "خطأ في الشبكة",
      "Timeout": "انتهى الوقت",
      "Invalid server response": "استجابة خادم غير صالحة",
      "The request took too long. Please try again.":
          "استغرقت الطلب وقتًا طويلاً. يرجى المحاولة مرة أخرى.",
      "An unexpected error occurred": "حدث خطأ غير متوقع",
      "Sign up failed, fill the textfields correctly":
          "فشل التسجيل، يرجى ملء الحقول بشكل صحيح",
      "Request timeout. Please try again.":
          "انتهت مهلة الطلب. يرجى المحاولة مرة أخرى.",
      "Number is already taken": "الرقم محجوز مسبقاً",
      "Username is already taken": "اسم المستخدم محجوز مسبقاً",
      "Username and number are already taken":
          "اسم المستخدم والرقم محجوزان مسبقاً",
      "All fields are required": "جميع الحقول مطلوبة",
      "Session expired. Please log in again.":
          "انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.",
      "Both old and new passwords are required":
          "كلمة السر القديمة والجديدة مطلوبتان",
      "Password changed successfully": "تم تغيير كلمة السر بنجاح",
      "Invalid old password": "كلمة السر القديمة غير صالحة",
      "Invalid request": "طلب غير صالح",
      "Network error. Please check your connection.":
          "خطأ في الشبكة. يرجى التحقق من اتصالك.",
      "Username cannot be empty": "اسم المستخدم لا يمكن أن يكون فارغًا",
      "Username must be at least 3 characters":
          "يجب أن يكون اسم المستخدم 3 أحرف على الأقل",
      "Username changed successfully": "تم تغيير اسم المستخدم بنجاح",
      "Username already taken": "اسم المستخدم محجوز مسبقاً",
      "Local session cleared": "تم مسح الجلسة المحلية",
      "Choose a teacher for more details": "اختر أستاذاً لمزيد من التفاصيل",
      "1. Information We Collect": "1. المعلومات التي نجمعها",
      "When you register, we collect the following:\n- Username: (to identify your account).\n- Password: (stored securely in hashed form for authentication).\n- Phone Number: (used for account identification and subscription management).":
          "عند التسجيل، نجمع المعلومات التالية:\n- اسم المستخدم: (لتحديد حسابك).\n- كلمة السر: (مخزنة بشكل آمن في شكل مشفر للمصادقة).\n- رقم الهاتف: (يستخدم لتحديد الحساب وإدارة الاشتراكات).",
      "2. How We Use Your Information": "2. كيف نستخدم معلوماتك",
      "- Username & Password: Used solely for login authentication.\n- Phone Number: Displayed on your profile and used by administrators to manage subscriptions.\n- We *do not* use your data for marketing, analytics, or third-party sharing.":
          "- اسم المستخدم وكلمة السر: تستخدم فقط لمصادقة تسجيل الدخول.\n- رقم الهاتف: يظهر في ملفك الشخصي ويستخدمه المشرفون لإدارة الاشتراكات.\n- نحن *لا* نستخدم بياناتك للتسويق أو التحليلات أو المشاركة مع أطراف ثالثة.",
      "3. Data Storage & Security": "3. تخزين البيانات والأمان",
      "- Your password is hashed (encrypted) and cannot be accessed even by administrators.\n- Phone numbers and usernames are stored securely in our database.\n- Only authorized administrators can access user data for management purposes.":
          "- كلمة السر مشفرة ولا يمكن الوصول إليها حتى من قبل المشرفين.\n- أرقام الهواتف وأسماء المستخدمين مخزنة بشكل آمن في قاعدة البيانات.\n- فقط المشرفون المصرح لهم يمكنهم الوصول إلى بيانات المستخدمين لأغراض الإدارة.",
      "4. No Third-Party Sharing": "4. لا مشاركة مع أطراف ثالثة",
      "- We *do not* share your data with advertisers, Google, Facebook, or any external services.\n- No automated sign-in (e.g., Google/Facebook login) is used.":
          "- نحن *لا* نشارك بياناتك مع المعلنين أو جوجل أو فيسبوك أو أي خدمات خارجية.\n- لا نستخدم تسجيل دخول تلقائي (مثل تسجيل الدخول عبر جوجل/فيسبوك).",
      "5. Your Rights": "5. حقوقك",
      "- You can request to:\n- View the personal data we store (username/phone number).\n- Update or delete your account (subject to admin approval).\n- Since passwords are hashed, they cannot be retrieved—only reset.":
          "- يمكنك طلب:\n- عرض البيانات الشخصية التي نخزنها (اسم المستخدم/رقم الهاتف).\n- تحديث أو حذف حسابك (خاضع لموافقة المشرف).\n- بما أن كلمات السر مشفرة، لا يمكن استرجاعها - فقط إعادة تعيينها.",
      "6. Changes to This Policy": "6. تغييرات على هذه السياسة",
      "Updates will be posted here with a new \"Last Updated\" date.":
          "سيتم نشر التحديثات هنا مع تاريخ \"آخر تحديث\" جديد.",
      "7. Contact Us": "7. اتصل بنا",
      "Welcome to Everything App!": "مرحبًا بكم في تطبيق إيفريثينغ!",
      "The purpose of this app is to \"save effort, time, and costs\" (such as lecture halls and transportation expenses). All our courses will be available in this app as \"well-organized and beautifully structured videos\".":
          "الغرض من هذا التطبيق هو \"توفير الجهد والوقت والتكاليف\" (مثل قاعات المحاضرات ومصاريف النقل). ستكون جميع دوراتنا متاحة في هذا التطبيق كـ \"مقاطع فيديو منظمة بشكل جيد وذات هيكلة جميلة\".",
      "- Username & Password: Used solely for login authentication.\n- Phone Number: Displayed on your profile and used by administrators to manage subscriptions.\n- We do not use your data for marketing, analytics, or third-party sharing.":
          "- اسم المستخدم وكلمة السر: تستخدم فقط لمصادقة تسجيل الدخول.\n- رقم الهاتف: يظهر في ملفك الشخصي ويستخدمه المشرفون لإدارة الاشتراكات.\n- نحن لا نستخدم بياناتك للتسويق أو التحليلات أو المشاركة مع أطراف ثالثة.",
      "- We do not share your data with advertisers, Google, Facebook, or any external services.\n- No automated sign-in (e.g., Google/Facebook login) is used.":
          "- نحن لا نشارك بياناتك مع المعلنين أو جوجل أو فيسبوك أو أي خدمات خارجية.\n- لا نستخدم تسجيل دخول تلقائي (مثل تسجيل الدخول عبر جوجل/فيسبوك).",
      "6. Account Usage & Device Restrictions":
          "6. استخدام الحساب وقيود الجهاز",
      "- Each account can only be used on one device at a time.\n- If you switch devices, you must contact our team to delete the old account before signing up again.\n- Subscriptions tied to your old account will be manually reinstated by our team after verification.":
          "- يمكن استخدام كل حساب على جهاز واحد فقط في كل مرة.\n- إذا قمت بتغيير الجهاز، يجب عليك الاتصال بفريقنا لحذف الحساب القديم قبل التسجيل مرة أخرى.\n- سيتم إعادة الاشتراكات المرتبطة بحسابك القديم يدويًا من قبل فريقنا بعد التحقق.",
      "7. Data Retention": "7. احتفاظ البيانات",
      "- When you request an account deletion (to migrate to a new device), your phone number, username, and subscription data may be retained temporarily to facilitate manual recovery.\n- Fully deleted accounts are irrecoverable unless you re-register and contact support.":
          "- عند طلب حذف الحساب (للانتقال إلى جهاز جديد)، قد نحتفظ برقم هاتفك واسم المستخدم وبيانات الاشتراك مؤقتًا لتسهيل الاستعادة اليدوية.\n- لا يمكن استعادة الحسابات المحذوفة بالكامل إلا إذا قمت بإعادة التسجيل والاتصال بالدعم.",
      "Light Mode": "الوضع الفاتح",
      "Dark Mode": "الوضع المظلم",
      "Telegram Group:": "مجموعة التليجرام:",
      "WhatsApp support:": "دعم واتساب:",
      "Announcements:": "الإعلانات:",
      "Connection error": "خطأ في الاتصال",
      "Connection access is needed": "مطلوب صلاحية الاتصال",
      "Subject not subscribed.": "المادة غير مشترك بها.",
      "Not subscribed!": "غير مشترك!",
      "You need to purchase the whole subject or this particular lecture in order to download it.":
          "يجب عليك شراء المادة كاملة أو هذه المحاضرة المحددة لتنزيلها.",
      "Storage and network access are needed": "مطلوب صلاحيات التخزين والشبكة",
      "Contact the support team for instructions on how to subscribe to the lecture/subject first.":
          "تواصل مع فريق الدعم للحصول على تعليمات حول كيفية الاشتراك في المحاضرة/المادة أولاً.",
      "OK": "موافق",
      "Problem fetching the lecture": "مشكلة في جلب المحاضرة",
      "Could not connect to the server. Please check your connection.":
          "تعذر الاتصال بالخادم. يرجى التحقق من اتصالك.",
      "Warning!": "تحذير!",
      "Taking Screenshots can cause a ban on your account.":
          "التقاط لقطات الشاشة قد يؤدي إلى حظر حسابك.",
      "Recording videos can cause a ban on your account.":
          "تسجيل الفيديو قد يؤدي إلى حظر حسابك.",
      "Banned Account!": "حساب محظور!",
      "Contact the support team to restore this account.":
          "تواصل مع فريق الدعم لاستعادة هذا الحساب.",
      "Old password is not correct": "كلمة المرور القديمة غير صحيحة",
      "Password changing failed": "فشل تغيير كلمة المرور",
      "Username changing failed": "فشل تغيير اسم المستخدم",
      "his username is already taken": "اسم المستخدم هذا محجوز مسبقاً",
      "Failed to load video: this quality is not available":
          "فشل تحميل الفيديو: هذه الجودة غير متوفرة",
      "Support team": "فريق الدعم",
      "WhatsApp": "واتساب",
      "Telegram": "تليجرام",
      "Username": "اسم المستخدم",
      "09XXXXXXXX": "09XXXXXXXX",
      "● Subscriptions:\n": "● الاشتراكات:\n",
      "\n● Lectures number: X": "\n● عدد المحاضرات: X",
      "● Number:": "● الرقم:",
      "360p": "360p",
      "720p": "720p",
      "1080p": "1080p",
      "Auto": "تلقائي",
      "Failed to load video": "فشل تحميل الفيديو",
      "Retry": "إعادة المحاولة",
      "Screen capture detected. This may lead to account suspension.":
          "تم اكتشاف التقاط الشاشة. قد يؤدي هذا إلى تعليق الحساب.",
      "Screen recording detected!": "تم اكتشاف تسجيل الشاشة!",
      "Screenshot detected!": "تم اكتشاف لقطة الشاشة!",
      "Connected to the internet": "متصل بالإنترنت",
      "This username is already taken": "اسم المستخدم هذا محجوز مسبقاً",
      "Username changing failed, connection access is needed":
          "فشل تغيير اسم المستخدم، مطلوب صلاحية الاتصال",
      "Support team:": "فريق الدعم:",
      "Choose a major": "اختر التخصص",
      "● Majors:": "● التخصصات:",
    },

    "De": {
      "Sign Up": "Registrieren",
      "Log In": "Anmelden",
      "Already have an account?": "Haben Sie bereits ein Konto?",
      "User Name": "Benutzername",
      "Please enter your User Name": "Bitte geben Sie Ihren Benutzernamen ein",
      "User Name must be longer than 3 characters":
          "Der Benutzername muss länger als 3 Zeichen sein",
      "User Name must be shorter than 20 characters":
          "Der Benutzername muss kürzer als 20 Zeichen sein",
      "Number": "Telefonnummer",
      "Please enter your Phone Number":
          "Bitte geben Sie Ihre Telefonnummer ein",
      "Phone Number must be : 09XXXXXXXX":
          "Die Telefonnummer muss im Format 09XXXXXXXX sein",
      "Phone Number must be 10 digits":
          "Die Telefonnummer muss 10 Ziffern lang sein",
      "Phone Number must ONLY contain numbers":
          "Die Telefonnummer darf nur Zahlen enthalten",
      "Password": "Passwort",
      "Please enter your password": "Bitte geben Sie Ihr Passwort ein",
      "Password must be at least 8 characters":
          "Das Passwort muss mindestens 8 Zeichen lang sein",
      "Confirm Password": "Passwort bestätigen",
      "Passwords do not match": "Passwörter stimmen nicht überein",
      "You don't have an account?": "Sie haben noch kein Konto?",
      "Your personal collection for your favorite subjects' lectures, that include videos filmed by the teachers themselves and PDF files that are comprehensive of your learning process, guaranteeing progress and utter improvement.":
          "Ihre persönliche Sammlung von Vorlesungen zu Ihren Lieblingsfächern, mit Videos der Lehrer und PDF-Dateien, die Ihren Lernprozess umfassend unterstützen und Fortschritt garantieren.",
      "Listen and watch as the teachers guide you in a comprehensive step-by-step journey for the subjects of your picking.":
          "Hören und sehen Sie zu, wie die Lehrer Sie Schritt für Schritt durch Ihre gewählten Fächer führen.",
      "Improve on your cognitive and creative abilities with the help of this compact yet simple app, each lecture right at your fingertips and at-the-ready, even when offline.":
          "Verbessern Sie Ihre kognitiven und kreativen Fähigkeiten mit dieser kompakten App - jede Vorlesung ist griffbereit, auch offline.",
      "Choose a lecture": "Wähle eine Vorlesung",
      "Choose a subject": "Wähle ein Fach",
      "Choose a teacher": "Wähle einen Lehrer",
      "Choose a university": "Wähle eine Universität",
      "Change Username": "Benutzernamen ändern",
      "Change Password": "Passwort ändern",
      "Language": "Sprache",
      "Theme": "Thema",
      "About Us": "Über uns",
      "Contact Us": "Kontakt",
      "Privacy Policy": "Datenschutz",
      "Log Out": "Abmelden",
      "Settings": "Einstellungen",
      "Teachers": "Lehrer",
      "Home Page": "Startseite",
      "Profile": "Profil",
      "Teacher Profile": "Lehrerprofil",
      "Damascus University": "Universität Damaskus",
      "Aleppo University": "Universität Aleppo",
      "Tishreen University": "Universität Tishreen",
      "Home": "Startseite",
      "lecture": "Vorlesung",
      "Subjects": "Fächer",
      "Usernames do not match": "Benutzernamen stimmen nicht überein",
      "Light mode": "Hellmodus",
      "Choose application's theme mode": "Wähle den App-Darstellungsmodus",
      "Choose application's language": "Wähle die App-Sprache",
      "English": "Englisch",
      "Arabic": "Arabisch",
      "German": "Deutsch",
      "Turkish": "Türkisch",
      "Error": "Fehler",
      "Failed to check connectivity:": "Verbindungsprüfung fehlgeschlagen:",
      "Please connect to the internet or you will have limited features":
          "Bitte mit dem Internet verbinden, sonst sind die Funktionen eingeschränkt",
      "Internet connection restored": "Internetverbindung wiederhergestellt",
      "Old Password": "Altes Passwort",
      "New Password": "Neues Passwort",
      "Please enter a New Password": "Bitte neues Passwort eingeben",
      "Please enter your OLD Password": "Bitte altes Passwort eingeben",
      "Please confirm your new password": "Bitte neues Passwort bestätigen",
      "No internet connection": "Keine Internetverbindung",
      "Confirm": "Bestätigen",
      "Confirm User Name": "Benutzernamen bestätigen",
      "Please confirm your Username": "Bitte Benutzernamen bestätigen",
      "Language code cannot be empty": "Sprachcode darf nicht leer sein",
      "Unsupported language code:": "Nicht unterstützter Sprachcode:",
      "Log In failed": "Anmeldung fehlgeschlagen",
      "Get Started": "Loslegen",
      "Continue": "Weiter",
      "Please enter A User Name": "Bitte Benutzernamen eingeben",
      "Please enter A Password": "Bitte Passwort eingeben",
      "Sign Up failed": "Registrierung fehlgeschlagen",
      "Video Player": "Videoplayer",
      "failed to change the username": "Benutzernamenänderung fehlgeschlagen",
      "failed to change the password": "Passwortänderung fehlgeschlagen",
      "● Subjects:": "● Fächer:",
      "● Universities:": "● Universitäten:",
      "Select Video Quality": "Videoqualität auswählen",
      "Don't have an account?": "Kein Konto?",
      "Log In failed, fill the textfields correctly":
          "Anmeldung fehlgeschlagen, bitte Felder korrekt ausfüllen",
      "Validation Error": "Validierungsfehler",
      "Username and password are required":
          "Benutzername und Passwort sind erforderlich",
      "Invalid Credentials": "Ungültige Anmeldedaten",
      "Please check your username and password":
          "Bitte Benutzernamen und Passwort überprüfen",
      "Unknown error occurred": "Unbekannter Fehler aufgetreten",
      "Network Error": "Netzwerkfehler",
      "Timeout": "Zeitüberschreitung",
      "Invalid server response": "Ungültige Serverantwort",
      "The request took too long. Please try again.":
          "Die Anfrage dauerte zu lange. Bitte versuchen Sie es erneut.",
      "An unexpected error occurred": "Ein unerwarteter Fehler ist aufgetreten",
      "Sign up failed, fill the textfields correctly":
          "Registrierung fehlgeschlagen, bitte Felder korrekt ausfüllen",
      "Request timeout. Please try again.":
          "Anfragezeitüberschreitung. Bitte versuchen Sie es erneut.",
      "Number is already taken": "Nummer ist bereits vergeben",
      "Username is already taken": "Benutzername ist bereits vergeben",
      "Username and number are already taken":
          "Benutzername und Nummer sind bereits vergeben",
      "All fields are required": "Alle Felder sind erforderlich",
      "Session expired. Please log in again.":
          "Sitzung abgelaufen. Bitte erneut anmelden.",
      "Both old and new passwords are required":
          "Sowohl altes als auch neues Passwort sind erforderlich",
      "Password changed successfully": "Passwort erfolgreich geändert",
      "Invalid old password": "Ungültiges altes Passwort",
      "Invalid request": "Ungültige Anfrage",
      "Network error. Please check your connection.":
          "Netzwerkfehler. Bitte Verbindung überprüfen.",
      "Username cannot be empty": "Benutzername darf nicht leer sein",
      "Username must be at least 3 characters":
          "Benutzername muss mindestens 3 Zeichen lang sein",
      "Username changed successfully": "Benutzername erfolgreich geändert",
      "Username already taken": "Benutzername bereits vergeben",
      "Local session cleared": "Lokale Sitzung gelöscht",
      "Choose a teacher for more details":
          "Wählen Sie einen Lehrer für weitere Details",
      "1. Information We Collect": "1. Informationen, die wir sammeln",
      "When you register, we collect the following:\n- Username: (to identify your account).\n- Password: (stored securely in hashed form for authentication).\n- Phone Number: (used for account identification and subscription management).":
          "Bei der Registrierung sammeln wir:\n- Benutzername: (zur Kontoverifizierung).\n- Passwort: (sicher verschlüsselt gespeichert).\n- Telefonnummer: (für Kontoverwaltung und Abonnements).",
      "2. How We Use Your Information": "2. Verwendung Ihrer Daten",
      "- Username & Password: Used solely for login authentication.\n- Phone Number: Displayed on your profile and used by administrators to manage subscriptions.\n- We *do not* use your data for marketing, analytics, or third-party sharing.":
          "- Benutzername & Passwort: Nur für die Anmeldung.\n- Telefonnummer: In Ihrem Profil sichtbar und von Administratoren für Abonnements verwendet.\n- Wir verwenden Ihre Daten *nicht* für Marketing, Analysen oder Dritte.",
      "3. Data Storage & Security": "3. Datenspeicherung & Sicherheit",
      "- Your password is hashed (encrypted) and cannot be accessed even by administrators.\n- Phone numbers and usernames are stored securely in our database.\n- Only authorized administrators can access user data for management purposes.":
          "- Ihr Passwort ist verschlüsselt (auch für Administratoren unlesbar).\n- Telefonnummern und Benutzernamen sicher gespeichert.\n- Nur autorisierte Administratoren haben Zugriff.",
      "4. No Third-Party Sharing": "4. Keine Weitergabe an Dritte",
      "- We *do not* share your data with advertisers, Google, Facebook, or any external services.\n- No automated sign-in (e.g., Google/Facebook login) is used.":
          "- Wir geben Daten *nicht* an Werbetreibende, Google, Facebook oder Dritte weiter.\n- Kein automatisches Login (z.B. via Google/Facebook).",
      "5. Your Rights": "5. Ihre Rechte",
      "- You can request to:\n- View the personal data we store (username/phone number).\n- Update or delete your account (subject to admin approval).\n- Since passwords are hashed, they cannot be retrieved—only reset.":
          "- Sie können:\n- Gespeicherte Daten einsehen (Benutzername/Telefonnummer).\n- Konto aktualisieren/löschen (mit Admin-Genehmigung).\n- Passwörter können nur zurückgesetzt (nicht abgerufen) werden.",
      "6. Changes to This Policy": "6. Änderungen dieser Richtlinie",
      "Updates will be posted here with a new \"Last Updated\" date.":
          "Aktualisierungen werden hier mit neuem \"Zuletzt aktualisiert\"-Datum veröffentlicht.",
      "7. Contact Us": "7. Kontakt",
      "Welcome to Everything App!": "Willkommen bei der Everything App!",
      "The purpose of this app is to \"save effort, time, and costs\" (such as lecture halls and transportation expenses). All our courses will be available in this app as \"well-organized and beautifully structured videos\".":
          "Diese App soll \"Aufwand, Zeit und Kosten sparen\" (wie Hörsäle und Transport). Alle Kurse sind als \"gut organisierte, strukturierte Videos\" verfügbar.",
      "- Username & Password: Used solely for login authentication.\n- Phone Number: Displayed on your profile and used by administrators to manage subscriptions.\n- We do not use your data for marketing, analytics, or third-party sharing.":
          "- Benutzername & Passwort: Nur zur Anmeldung.\n- Telefonnummer: Wird in Ihrem Profil angezeigt und von Administratoren für Abonnements verwendet.\n- Wir verwenden Ihre Daten nicht für Marketing, Analysen oder Dritte.",
      "- We do not share your data with advertisers, Google, Facebook, or any external services.\n- No automated sign-in (e.g., Google/Facebook login) is used.":
          "- Wir geben keine Daten an Werbetreibende, Google, Facebook oder Dritte weiter.\n- Kein automatisches Login (z.B. via Google/Facebook).",
      "6. Account Usage & Device Restrictions":
          "6. Kontonutzung & Geräteeinschränkungen",
      "- Each account can only be used on one device at a time.\n- If you switch devices, you must contact our team to delete the old account before signing up again.\n- Subscriptions tied to your old account will be manually reinstated by our team after verification.":
          "- Jedes Konto kann nur auf einem Gerät genutzt werden.\n- Bei Gerätewechsel muss unser Team das alte Konto löschen, bevor Sie sich neu anmelden.\n- Abonnements werden nach Überprüfung manuell übertragen.",
      "7. Data Retention": "7. Datenaufbewahrung",
      "- When you request an account deletion (to migrate to a new device), your phone number, username, and subscription data may be retained temporarily to facilitate manual recovery.\n- Fully deleted accounts are irrecoverable unless you re-register and contact support.":
          "- Bei Kontolöschung (für Gerätewechsel) können Telefonnummer, Benutzername und Abonnementdaten vorübergehend gespeichert werden.\n- Vollständig gelöschte Konten sind unwiederbringlich verloren.",
      "Light Mode": "Hellmodus",
      "Dark Mode": "Dunkelmodus",
      "Telegram Group:": "Telegram-Gruppe:",
      "WhatsApp support:": "WhatsApp-Support:",
      "Announcements:": "Ankündigungen:",
      "Connection error": "Verbindungsfehler",
      "Connection access is needed": "Verbindungsberechtigung erforderlich",
      "Subject not subscribed.": "Fach nicht abonniert.",
      "Not subscribed!": "Nicht abonniert!",
      "You need to purchase the whole subject or this particular lecture in order to download it.":
          "Sie müssen das gesamte Fach oder diese Vorlesung kaufen, um sie herunterzuladen.",
      "Storage and network access are needed":
          "Speicher- und Netzwerkberechtigungen erforderlich",
      "Contact the support team for instructions on how to subscribe to the lecture/subject first.":
          "Kontaktieren Sie das Support-Team für Anweisungen zum Abonnieren der Vorlesung/des Fachs.",
      "OK": "OK",
      "Problem fetching the lecture": "Problem beim Abrufen der Vorlesung",
      "Could not connect to the server. Please check your connection.":
          "Verbindung zum Server nicht möglich. Bitte überprüfen Sie Ihre Verbindung.",
      "Warning!": "Warnung!",
      "Taking Screenshots can cause a ban on your account.":
          "Screenshots können zu einem Konto-Bann führen.",
      "Recording videos can cause a ban on your account.":
          "Videoaufnahmen können zu einem Konto-Bann führen.",
      "Banned Account!": "Konto gesperrt!",
      "Contact the support team to restore this account.":
          "Kontaktieren Sie das Support-Team zur Wiederherstellung dieses Kontos.",
      "Old password is not correct": "Altes Passwort ist nicht korrekt",
      "Password changing failed": "Passwortänderung fehlgeschlagen",
      "Username changing failed": "Benutzernamenänderung fehlgeschlagen",
      "his username is already taken":
          "dieser Benutzername ist bereits vergeben",
      "Failed to load video: this quality is not available":
          "Video konnte nicht geladen werden: diese Qualität ist nicht verfügbar",
      "Support team": "Support-Team",
      "WhatsApp": "WhatsApp",
      "Telegram": "Telegram",
      "Username": "Benutzername",
      "09XXXXXXXX": "09XXXXXXXX",
      "● Subscriptions:\n": "● Abonnements:\n",
      "\n● Lectures number: X": "\n● Anzahl der Vorlesungen: X",
      "● Number:": "● Nummer:",
      "360p": "360p",
      "720p": "720p",
      "1080p": "1080p",
      "Auto": "Auto",
      "Failed to load video": "Video konnte nicht geladen werden",
      "Retry": "Wiederholen",
      "Screen capture detected. This may lead to account suspension.":
          "Bildschirmaufnahme erkannt. Dies kann zur Kontosperrung führen.",
      "Screen recording detected!": "Bildschirmaufzeichnung erkannt!",
      "Screenshot detected!": "Screenshot erkannt!",
      "Connected to the internet": "Mit dem Internet verbunden",
      "This username is already taken":
          "Dieser Benutzername ist bereits vergeben",
      "Username changing failed, connection access is needed":
          "Benutzernamenänderung fehlgeschlagen, Verbindungszugriff erforderlich",
      "Support team:": "Support-Team:",
      "Choose a major": "Wählen Sie einen Studiengang",
      "● Majors:": "● Studiengänge:",
    },
    "Es": {
      "Sign Up": "Registrarse",
      "Log In": "Iniciar Sesión",
      "Already have an account?": "¿Ya tienes una cuenta?",
      "User Name": "Nombre de Usuario",
      "Please enter your User Name": "Por favor ingrese su nombre de usuario",
      "User Name must be longer than 3 characters":
          "El nombre de usuario debe tener más de 3 caracteres",
      "User Name must be shorter than 20 characters":
          "El nombre de usuario debe tener menos de 20 caracteres",
      "Number": "Número",
      "Please enter your Phone Number":
          "Por favor ingrese su número de teléfono",
      "Phone Number must be : 09XXXXXXXX":
          "El número de teléfono debe ser: 09XXXXXXXX",
      "Phone Number must be 10 digits":
          "El número de teléfono debe tener 10 dígitos",
      "Phone Number must ONLY contain numbers":
          "El número de teléfono solo debe contener números",
      "Password": "Contraseña",
      "Please enter your password": "Por favor ingrese su contraseña",
      "Password must be at least 8 characters":
          "La contraseña debe tener al menos 8 caracteres",
      "Confirm Password": "Confirmar Contraseña",
      "Passwords do not match": "Las contraseñas no coinciden",
      "You don't have an account?": "¿No tienes una cuenta?",
      "Your personal collection for your favorite subjects' lectures, that include videos filmed by the teachers themselves and PDF files that are comprehensive of your learning process, guaranteeing progress and utter improvement.":
          "Tu colección personal de conferencias de tus materias favoritas, que incluyen videos filmados por los propios profesores y archivos PDF que son completos para tu proceso de aprendizaje, garantizando progreso y mejora total.",
      "Listen and watch as the teachers guide you in a comprehensive step-by-step journey for the subjects of your picking.":
          "Escucha y mira mientras los profesores te guían en un viaje paso a paso completo para las materias de tu elección.",
      "Improve on your cognitive and creative abilities with the help of this compact yet simple app, each lecture right at your fingertips and at-the-ready, even when offline.":
          "Mejora tus habilidades cognitivas y creativas con la ayuda de esta aplicación compacta pero simple, cada conferencia al alcance de tu mano y lista para usar, incluso sin conexión.",
      "Change Username": "Cambiar Nombre de Usuario",
      "Change Password": "Cambiar Contraseña",
      "Language": "Idioma",
      "Theme": "Tema",
      "About Us": "Sobre Nosotros",
      "Contact Us": "Contáctenos",
      "Privacy Policy": "Política de Privacidad",
      "Log Out": "Cerrar Sesión",
      "Settings": "Configuración",
      "Teachers": "Profesores",
      "Home Page": "Página Principal",
      "Profile": "Perfil",
      "Choose a lecture": "Elige una conferencia",
      "Choose a subject": "Elige una materia",
      "Choose a teacher": "Elige un profesor",
      "Choose a university": "Elige una universidad",
      "Teacher Profile": "Profil del profesor",
      "Damascus University": "Universidad de Damas",
      "Aleppo University": "Universidad de Alep",
      "Tishreen University": "Universidad de Tishreen",
      "Home": "Inicio",
      "lecture": "conferencia",
      "Subjects": "Materias",
      "Usernames do not match": "Los nombres de usuario no coinciden",
      "Light mode": "Modo claro",
      "Choose application's theme mode":
          "Elige el modo de tema de la aplicación",
      "Choose application's language": "Elige el idioma de la aplicación",
      "English": "Inglés",
      "Arabic": "Árabe",
      "German": "Alemán",
      "Turkish": "Turco",
      "Error": "Erreur",
      "Failed to check connectivity:":
          "Échec de la vérification de la connectivité :",
      "Please connect to the internet or you will have limited features":
          "Veuillez vous connecter à Internet ou vous aurez des fonctionnalités limitées",
      "Internet connection restored": "Connexion Internet rétablie",
      "Old Password": "Ancien mot de passe",
      "New Password": "Nouveau mot de passe",
      "Please enter a New Password": "Veuillez entrer un nouveau mot de passe",
      "Please enter your OLD Password":
          "Veuillez entrer votre ancien mot de passe",
      "Please confirm your new password":
          "Veuillez confirmer votre nouveau mot de passe",
      "No internet connection": "Pas de connexion Internet",
      "Confirm": "Confirmer",
      "Confirm User Name": "Confirmer le nom d'utilisateur",
      "Please confirm your Username":
          "Veuillez confirmer votre nom d'utilisateur",
      "Language code cannot be empty":
          "Le code de langue ne peut pas être vide",
      "Unsupported language code:": "Code de langue non pris en charge :",
      "Log In failed": "Échec de la connexion",
      "Get Started": "Commencer",
      "Continue": "Continuer",
      "Please enter A User Name": "Veuillez entrer un nom d'utilisateur",
      "Please enter A Password": "Veuillez entrer un mot de passe",
      "Sign Up failed": "Échec de l'inscription",
      "Video Player": "Lecteur vidéo",
      "failed to change the username":
          "Échec du changement de nom d'utilisateur",
      "failed to change the password": "Échec du changement de mot de passe",
      "● Subjects:": "● Matières :",
      "● Universities:": "● Universités :",
      "Select Video Quality": "Sélectionner la qualité vidéo",
      "Don't have an account?": "Vous n'avez pas de compte ?",
      "Log In failed, fill the textfields correctly":
          "Échec de la connexion, remplissez correctement les champs",
      "Validation Error": "Erreur de validation",
      "Username and password are required":
          "Le nom d'utilisateur et le mot de passe sont requis",
      "Invalid Credentials": "Identifiants invalides",
      "Please check your username and password":
          "Veuillez vérifier votre nom d'utilisateur et mot de passe",
      "Unknown error occurred": "Une erreur inconnue s'est produite",
      "Network Error": "Erreur réseau",
      "Timeout": "Délai d'attente dépassé",
      "Invalid server response": "Réponse du serveur inválida",
      "The request took too long. Please try again.":
          "La requête a pris trop de temps. Veuillez réessayer.",
      "An unexpected error occurred": "Une erreur inattendue s'est produite",
      "Sign up failed, fill the textfields correctly":
          "Échec de l'inscription, remplissez correctement les champs",
      "Request timeout. Please try again.":
          "Délai d'attente de la requête dépassé. Veuillez réessayer.",
      "Number is already taken": "El número ya está en uso",
      "Username is already taken": "El nombre de usuario ya está en uso",
      "Username and number are already taken":
          "El nombre de usuario y número ya están en uso",
      "All fields are required": "Todos los champs son requis",
      "Session expired. Please log in again.":
          "Session expirée. Veuillez vous reconnecter.",
      "Both old and new passwords are required":
          "L'ancien et le nouveau mot de passe sont requis",
      "Password changed successfully": "Mot de passe changé avec succès",
      "Invalid old password": "Ancien mot de passe invalide",
      "Invalid request": "Requête invalide",
      "Network error. Please check your connection.":
          "Erreur réseau. Veuillez vérifier votre connexion.",
      "Username cannot be empty": "Le nom d'utilisateur ne peut pas être vide",
      "Username must be at least 3 characters":
          "Le nom d'utilisateur doit contenir au moins 3 caractères",
      "Username changed successfully": "Nom d'utilisateur changé avec succès",
      "Username already taken": "El nombre de usuario ya está en uso",
      "Local session cleared": "Session locale effacée",
      "Choose a teacher for more details":
          "Elige un profesor para más detalles",
      "Light Mode": "Modo Claro",
      "Dark Mode": "Modo Oscuro",
      "Telegram Group:": "Grupo de Telegram :",
      "WhatsApp support:": "Soporte WhatsApp :",
      "Announcements:": "Anuncios :",
      "Connection error": "Erreur de connexion",
      "Connection access is needed": "L'accès à la connexion est nécessaire",
      "Subject not subscribed.": "Matière no suscritte.",
      "Not subscribed!": "Non souscrit !",
      "You need to purchase the whole subject or this particular lecture in order to download it.":
          "Vous devez acheter la matière complète ou cette conférence particulière pour la télécharger.",
      "Storage and network access are needed":
          "L'accès au stockage et au réseau est nécessaire",
      "Contact the support team for instructions on how to subscribe to the lecture/subject first.":
          "Contactez l'équipe de support pour obtenir des instructions sur la façon de vous abonner à la conférence/matière d'abord.",
      "OK": "OK",
      "Problem fetching the lecture":
          "Problème lors de la récupération de la conférence",
      "Could not connect to the server. Please check your connection.":
          "Impossible de se connecter au serveur. Veuillez vérifier votre connexion.",
      "Warning!": "Attention !",
      "Taking Screenshots can cause a ban on your account.":
          "La prise de captures d'écran peut entraîner le bannissement de votre compte.",
      "Recording videos can cause a ban on your account.":
          "L'enregistrement de vidéos peut entraîner le bannissement de votre compte.",
      "Banned Account!": "Compte banni !",
      "Contact the support team to restore this account.":
          "Contactez l'équipe de support pour restaurer ce compte.",
      "Old password is not correct": "L'ancien mot de passe n'est pas correct",
      "Password changing failed": "Échec du changement de mot de passe",
      "Username changing failed": "Échec du changement de nom d'utilisateur",
      "his username is already taken": "ce nom d'utilisateur est déjà pris",
      "Failed to load video: this quality is not available":
          "Échec du chargement de la vidéo : cette qualité n'est pas disponible",
      "Support team": "Équipe de support",
      "WhatsApp": "WhatsApp",
      "Telegram": "Telegram",
      "Username": "Nom d'utilisateur",
      "09XXXXXXXX": "09XXXXXXXX",
      "● Subscriptions:\n": "● Abonnements :\n",
      "\n● Lectures number: X": "\n● Número de conférences : X",
      "● Number:": "● Numéro :",
      "360p": "360p",
      "720p": "720p",
      "1080p": "1080p",
      "Auto": "Auto",
      "Failed to load video": "Échec du chargement de la vidéo",
      "Retry": "Réessayer",
      "Screen capture detected. This may lead to account suspension.":
          "Capture d'écran détectée. Cela peut entraîner la suspension du compte.",
      "Screen recording detected!": "Enregistrement d'écran détecté !",
      "Screenshot detected!": "Capture d'écran détectée !",
      "Connected to the internet": "Connecté à Internet",
      "This username is already taken": "Ce nom d'utilisateur ya está en uso",
      "Username changing failed, connection access is needed":
          "Échec du changement de nom d'utilisateur, l'accès à la connexion est nécessaire",
      "Support team:": "Équipe de support :",
      "Choose a major": "Elige una especialidad",
      "● Majors:": "● Especialidades :",
    },
    "Fr": {
      "Sign Up": "S'inscrire",
      "Log In": "Se connecter",
      "Already have an account?": "Vous avez déjà un compte ?",
      "User Name": "Nom d'utilisateur",
      "Please enter your User Name": "Veuillez entrer votre nom d'utilisateur",
      "User Name must be longer than 3 characters":
          "Le nom d'utilisateur doit contenir plus de 3 caractères",
      "User Name must be shorter than 20 characters":
          "Le nom d'utilisateur doit contenir moins de 20 caractères",
      "Number": "Numéro",
      "Please enter your Phone Number":
          "Veuillez entrer votre numéro de téléphone",
      "Phone Number must be : 09XXXXXXXX":
          "Le numéro de téléphone doit être : 09XXXXXXXX",
      "Phone Number must be 10 digits":
          "Le numéro de téléphone doit contenir 10 chiffres",
      "Phone Number must ONLY contain numbers":
          "Le numéro de téléphone ne doit contenir que des chiffres",
      "Password": "Mot de passe",
      "Please enter your password": "Veuillez entrer votre mot de passe",
      "Password must be at least 8 characters":
          "Le mot de passe doit contenir au moins 8 caractères",
      "Confirm Password": "Confirmer le mot de passe",
      "Passwords do not match": "Les mots de passe ne correspondent pas",
      "You don't have an account?": "Vous n'avez pas de compte ?",
      "Your personal collection for your favorite subjects' lectures, that include videos filmed by the teachers themselves and PDF files that are comprehensive of your learning process, guaranteeing progress and utter improvement.":
          "Votre collection personnelle de conférences pour vos matières préférées, comprenant des vidéos filmées par les professeurs eux-mêmes et des fichiers PDF complets pour votre processus d'apprentissage, garantissant progrès et amélioration totale.",
      "Listen and watch as the teachers guide you in a comprehensive step-by-step journey for the subjects of your picking.":
          "Écoutez et regardez les professeurs vous guider dans un parcours étape par étape complet pour les matières de votre choix.",
      "Improve on your cognitive and creative abilities with the help of this compact yet simple app, each lecture right at your fingertips and at-the-ready, even when offline.":
          "Améliorez vos capacités cognitives et créatives avec l'aide de cette application compacte mais simple, chaque conférence à portée de main et prête à l'emploi, même hors ligne.",
      "Change Username": "Changer le nom d'utilisateur",
      "Change Password": "Changer le mot de passe",
      "Language": "Langue",
      "Theme": "Thème",
      "About Us": "À propos",
      "Contact Us": "Contactez-nous",
      "Privacy Policy": "Politique de confidentialité",
      "Log Out": "Se déconnecter",
      "Settings": "Paramètres",
      "Teachers": "Professeurs",
      "Home Page": "Page d'accueil",
      "Profile": "Profil",
      "Choose a lecture": "Choisir une conférence",
      "Choose a subject": "Choisir une matière",
      "Choose a teacher": "Choisir un professeur",
      "Choose a university": "Choisir une université",
      "Teacher Profile": "Profil du professeur",
      "Damascus University": "Université de Damas",
      "Aleppo University": "Université d'Alep",
      "Tishreen University": "Université de Tishreen",
      "Home": "Accueil",
      "lecture": "conférence",
      "Subjects": "Matières",
      "Usernames do not match": "Les noms d'utilisateur ne correspondent pas",
      "Light mode": "Mode clair",
      "Choose application's theme mode":
          "Choisir le mode de thème de l'application",
      "Choose application's language": "Choisir la langue de l'application",
      "English": "Anglais",
      "Arabic": "Arabe",
      "German": "Allemand",
      "Turkish": "Turc",
      "Error": "Erreur",
      "Failed to check connectivity:":
          "Échec de la vérification de la connectivité :",
      "Please connect to the internet or you will have limited features":
          "Veuillez vous connecter à Internet ou vous aurez des fonctionnalités limitées",
      "Internet connection restored": "Connexion Internet rétablie",
      "Old Password": "Ancien mot de passe",
      "New Password": "Nouveau mot de passe",
      "Please enter a New Password": "Veuillez entrer un nouveau mot de passe",
      "Please enter your OLD Password":
          "Veuillez entrer votre ancien mot de passe",
      "Please confirm your new password":
          "Veuillez confirmer votre nouveau mot de passe",
      "No internet connection": "Pas de connexion Internet",
      "Confirm": "Confirmer",
      "Confirm User Name": "Confirmer le nom d'utilisateur",
      "Please confirm your Username":
          "Veuillez confirmer votre nom d'utilisateur",
      "Language code cannot be empty":
          "Le code de langue ne peut pas être vide",
      "Unsupported language code:": "Code de langue non pris en charge :",
      "Log In failed": "Échec de la connexion",
      "Get Started": "Commencer",
      "Continue": "Continuer",
      "Please enter A User Name": "Veuillez entrer un nom d'utilisateur",
      "Please enter A Password": "Veuillez entrer un mot de passe",
      "Sign Up failed": "Échec de l'inscription",
      "Video Player": "Lecteur vidéo",
      "failed to change the username":
          "Échec du changement de nom d'utilisateur",
      "failed to change the password": "Échec du changement de mot de passe",
      "● Subjects:": "● Matières :",
      "● Universities:": "● Universités :",
      "Select Video Quality": "Sélectionner la qualité vidéo",
      "Don't have an account?": "Vous n'avez pas de compte ?",
      "Log In failed, fill the textfields correctly":
          "Échec de la connexion, remplissez correctement les champs",
      "Validation Error": "Erreur de validation",
      "Username and password are required":
          "Le nom d'utilisateur et le mot de passe sont requis",
      "Invalid Credentials": "Identifiants invalides",
      "Please check your username and password":
          "Veuillez vérifier votre nom d'utilisateur et mot de passe",
      "Unknown error occurred": "Une erreur inconnue s'est produite",
      "Network Error": "Erreur réseau",
      "Timeout": "Délai d'attente dépassé",
      "Invalid server response": "Réponse du serveur invalide",
      "The request took too long. Please try again.":
          "La requête a pris trop de temps. Veuillez réessayer.",
      "An unexpected error occurred": "Une erreur inattendue s'est produite",
      "Sign up failed, fill the textfields correctly":
          "Échec de l'inscription, remplissez correctement les champs",
      "Request timeout. Please try again.":
          "Délai d'attente de la requête dépassé. Veuillez réessayer.",
      "Number is already taken": "Le numéro est déjà utilisé",
      "Username is already taken": "Le nom d'utilisateur est déjà utilisé",
      "Username and number are already taken":
          "Le nom d'utilisateur et le numéro sont déjà utilisés",
      "All fields are required": "Tous les champs sont requis",
      "Session expired. Please log in again.":
          "Session expirée. Veuillez vous reconnecter.",
      "Both old and new passwords are required":
          "L'ancien et le nouveau mot de passe sont requis",
      "Password changed successfully": "Mot de passe changé avec succès",
      "Invalid old password": "Ancien mot de passe invalide",
      "Invalid request": "Requête invalide",
      "Network error. Please check your connection.":
          "Erreur réseau. Veuillez vérifier votre connexion.",
      "Username cannot be empty": "Le nom d'utilisateur ne peut pas être vide",
      "Username must be at least 3 characters":
          "Le nom d'utilisateur doit contenir au moins 3 caractères",
      "Username changed successfully": "Nom d'utilisateur changé avec succès",
      "Username already taken": "Le nom d'utilisateur est déjà utilisé",
      "Local session cleared": "Session locale effacée",
      "Choose a teacher for more details":
          "Choisissez un professeur pour plus de détails",
      "Light Mode": "Mode clair",
      "Dark Mode": "Mode sombre",
      "Telegram Group:": "Groupe Telegram :",
      "WhatsApp support:": "Support WhatsApp :",
      "Announcements:": "Annonces :",
      "Connection error": "Erreur de connexion",
      "Connection access is needed": "L'accès à la connexion est nécessaire",
      "Subject not subscribed.": "Matière no suscritte.",
      "Not subscribed!": "Non souscrit !",
      "You need to purchase the whole subject or this particular lecture in order to download it.":
          "Vous devez acheter la matière complète ou cette conférence particulière pour la télécharger.",
      "Storage and network access are needed":
          "L'accès au stockage et au réseau est nécessaire",
      "Contact the support team for instructions on how to subscribe to the lecture/subject first.":
          "Contactez l'équipe de support pour obtenir des instructions sur la façon de vous abonner à la conférence/matière d'abord.",
      "OK": "OK",
      "Problem fetching the lecture":
          "Problème lors de la récupération de la conférence",
      "Could not connect to the server. Please check your connection.":
          "Impossible de se connecter au serveur. Veuillez vérifier votre connexion.",
      "Warning!": "Attention !",
      "Taking Screenshots can cause a ban on your account.":
          "La prise de captures d'écran peut entraîner le bannissement de votre compte.",
      "Recording videos can cause a ban on your account.":
          "L'enregistrement de vidéos peut entraîner le bannissement de votre compte.",
      "Banned Account!": "Compte banni !",
      "Contact the support team to restore this account.":
          "Contactez l'équipe de support pour restaurer ce compte.",
      "Old password is not correct": "L'ancien mot de passe n'est pas correct",
      "Password changing failed": "Échec du changement de mot de passe",
      "Username changing failed": "Échec du changement de nom d'utilisateur",
      "his username is already taken": "ce nom d'utilisateur est déjà pris",
      "Failed to load video: this quality is not available":
          "Échec du chargement de la vidéo : cette qualité n'est pas disponible",
      "Support team": "Équipe de support",
      "WhatsApp": "WhatsApp",
      "Telegram": "Telegram",
      "Username": "Nom d'utilisateur",
      "09XXXXXXXX": "09XXXXXXXX",
      "● Subscriptions:\n": "● Abonnements :\n",
      "\n● Lectures number: X": "\n● Número de conférences : X",
      "● Number:": "● Numéro :",
      "360p": "360p",
      "720p": "720p",
      "1080p": "1080p",
      "Auto": "Auto",
      "Failed to load video": "Échec du chargement de la vidéo",
      "Retry": "Réessayer",
      "Screen capture detected. This may lead to account suspension.":
          "Capture d'écran détectée. Cela peut entraîner la suspension du compte.",
      "Screen recording detected!": "Enregistrement d'écran détecté !",
      "Screenshot detected!": "Capture d'écran détectée !",
      "Connected to the internet": "Connecté à Internet",
      "This username is already taken": "Ce nom d'utilisateur ya está en uso",
      "Username changing failed, connection access is needed":
          "Échec du changement de nom d'utilisateur, l'accès à la connexion est nécessaire",
      "Support team:": "Équipe de support :",
      "Choose a major": "Elige una especialidad",
      "● Majors:": "● Spécialités:",
    },
  };
}
