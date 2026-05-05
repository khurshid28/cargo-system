import { createContext, useContext, useState, useEffect, ReactNode } from 'react';

export type Lang = 'uz' | 'ru';

const DICT: Record<Lang, Record<string, string>> = {
  uz: {
    // Navbar
    'nav.features': 'Imkoniyatlar',
    'nav.how': 'Qanday ishlaydi',
    'nav.apps': 'Ilovalar',
    'nav.pricing': 'Tariflar',
    'nav.faq': 'Savollar',
    'nav.contact': 'Aloqa',
    'nav.cta': 'Boshlash',

    // Hero
    'hero.badge': 'O‘zbekiston bo‘ylab — 24/7',
    'hero.title.a': 'Yukingiz uchun',
    'hero.title.b': 'eng yaqin haydovchi',
    'hero.title.c': 'bir tugma narida',
    'hero.subtitle':
      'Cargo — yuk yuboruvchi va haydovchilarni bog‘lovchi yagona logistika platformasi. Tezkor zakaz, real-time kuzatuv, ishonchli to‘lov.',
    'hero.cta.start': 'Hoziroq boshlash',
    'hero.cta.how': 'Qanday ishlaydi',
    'hero.users': '10,000+ foydalanuvchi',
    'hero.usersSub': 'platformaga ishonadi',
    'hero.delivered': 'Yetkazildi',
    'hero.onTheWay': 'Hozir yo‘lda',
    'hero.cargoCount': '12 ta yuk · 4 viloyat',

    // Stats
    'stats.users': 'Faol foydalanuvchilar',
    'stats.drivers': 'Tasdiqlangan haydovchilar',
    'stats.orders': 'Yetkazilgan zakaz',
    'stats.regions': 'Viloyat qamrovi',

    // Coverage
    'coverage.eyebrow': 'Qamrov hududi',
    'coverage.title.a': 'O‘zbekiston bo‘ylab',
    'coverage.title.b': 'va undan tashqarida',
    'coverage.subtitle':
      'Yuklaringizni viloyat ichida, shahar bo‘ylab yoki xalqaro yo‘nalishlarda yetkazamiz.',
    'coverage.tab.regions': 'Shaharlararo',
    'coverage.tab.cities': 'Shahar ichida',
    'coverage.tab.world': 'Xalqaro',
    'coverage.note': 'Har kuni yangi yo‘nalishlar qo‘shilmoqda',

    // Features
    'features.badge': 'Imkoniyatlar',
    'features.title.a': 'Logistikani',
    'features.title.b': 'soddalashtirdik',
    'features.subtitle': 'Bir nechta tugma bilan yukingizni ishonchli yetkazib bering.',
    'features.f1.title': 'Tezkor topish',
    'features.f1.desc': 'Yaqin atrofdagi mos haydovchi avtomatik topiladi.',
    'features.f2.title': 'Real-time kuzatuv',
    'features.f2.desc': 'Yukingiz qayerda — har soniyada xaritada.',
    'features.f3.title': 'Tasdiqlangan haydovchilar',
    'features.f3.desc': 'Hujjatlar va haydovchilik tarixi tekshirilgan.',
    'features.f4.title': 'Xavfsiz to‘lov',
    'features.f4.desc': 'Click, Payme va Uzum orqali bevosita to‘lash.',
    'features.f5.title': 'Ichki chat',
    'features.f5.desc': 'Haydovchi bilan to‘g‘ridan-to‘g‘ri muloqot.',
    'features.f6.title': 'Optimal yo‘nalish',
    'features.f6.desc': 'Eng qisqa va arzon yo‘nalish hisoblanadi.',

    // Apps
    'apps.badge': 'Ekosistema',
    'apps.title.a': 'Bir nechta',
    'apps.title.b': 'ilovalar',
    'apps.title.c': '— yagona platforma',
    'apps.subtitle':
      'Har bir foydalanuvchi roli uchun alohida tajriba: yuk yuboruvchi, haydovchi, xaridor.',
    'apps.sender.name': 'Yuk yuboruvchi',
    'apps.sender.desc':
      'Yuk yuboruvchilar uchun mobil ilova va veb-portal — A→B yuk so‘rovi, real-time kuzatuv.',
    'apps.driver.name': 'Haydovchi',
    'apps.driver.desc':
      'Haydovchilar uchun ilova — onlayn rejim, buyurtmalar, daromad va balans.',
    'apps.customer.name': 'Xaridor',
    'apps.customer.desc':
      'MaterialMarket xaridorlari uchun — qurilish materiallarini onlayn buyurtma qilish.',

    // How it works
    'how.badge': 'Qanday ishlaydi',
    'how.title': '4 ta oddiy qadam',
    'how.s1.title': 'Zakaz yarating',
    'how.s1.desc': 'Yuk turi, og‘irligi va manzilni kiriting. Narx avtomatik hisoblanadi.',
    'how.s2.title': 'Haydovchini tanlang',
    'how.s2.desc': 'Sizga eng yaqin va mos haydovchi yuboriladi.',
    'how.s3.title': 'Real-time kuzating',
    'how.s3.desc': 'Yukingiz qayerga yetganini xaritada onlayn ko‘ring.',
    'how.s4.title': 'To‘lang va baholang',
    'how.s4.desc': 'Yuk yetkazilganidan keyin to‘lov va baholash.',

    // Partners
    'partners.badge': 'Hamkorlarimiz',
    'partners.title.a': 'Yetakchi',
    'partners.title.b': 'ishlab chiqaruvchi',
    'partners.title.c': 'va bizneslar bilan',
    'partners.subtitle':
      'O‘zbekistonning yirik zavodlari, ishlab chiqaruvchilari va riteyl tarmoqlari o‘z mahsulotlarini Cargo orqali yetkazib beradi.',

    // Testimonials
    'testimonials.badge': 'Foydalanuvchilar',
    'testimonials.title': 'Mijozlarimiz fikri',
    'testimonials.subtitle': 'Minglab haydovchi, biznes va xaridorlar bizga ishonadi.',
    'testimonials.q1.text':
      'Cargo orqali kunlik 5–6 ta buyurtma olaman. Daromad oshdi, balansni darrov yechib olaman.',
    'testimonials.q1.role': 'Haydovchi',
    'testimonials.q2.text':
      'Mahsulotlarni viloyatlarga yuborish endi 2 daqiqada hal bo‘ladi. Real-time kuzatuv ajoyib.',
    'testimonials.q2.role': 'Marketing menejeri',
    'testimonials.q3.text':
      'MaterialMarket orqali sement va g‘ishtni to‘g‘ridan-to‘g‘ri zavoddan oldim — 30% arzon.',
    'testimonials.q3.role': 'Qurilish kompaniyasi',

    // Pricing
    'pricing.badge': 'Tariflar',
    'pricing.title.a': 'O‘zingizga mos',
    'pricing.title.b': 'rejani tanlang',
    'pricing.subtitle':
      'Barcha rejalarda asosiy funksiyalar mavjud. Yashirin to‘lov yo‘q — istalgan vaqt bekor qilasiz.',
    'pricing.popular': 'ENG MASHHUR',
    'pricing.perMonth': 'so‘m / oy',
    'pricing.note': '* Narxlar QQS bilan. Yillik to‘lovda 2 oy BEPUL.',

    'pricing.starter.name': 'Boshlang‘ich',
    'pricing.starter.price': 'Bepul',
    'pricing.starter.desc': 'Yakka shaxslar va kichik yuborishlar uchun.',
    'pricing.starter.f1': 'Oyiga 5 ta yuk so‘rovi',
    'pricing.starter.f2': 'Asosiy real-time kuzatuv',
    'pricing.starter.f3': 'Email orqali yordam',
    'pricing.starter.f4': 'Yuk sug‘urtasi 5 mln so‘mgacha',
    'pricing.starter.cta': 'Bepul boshlash',

    'pricing.business.name': 'Biznes',
    'pricing.business.desc': 'O‘sayotgan kompaniyalar va do‘konlar uchun.',
    'pricing.business.f1': 'Cheksiz yuk so‘rovi',
    'pricing.business.f2': 'Real-time xarita + ETA',
    'pricing.business.f3': 'Haydovchini tanlash imkoni',
    'pricing.business.f4': 'Tarix, hisobot va analitika',
    'pricing.business.f5': 'Telegram + SMS + Email bildirishnomalar',
    'pricing.business.f6': 'Yuk sug‘urtasi 50 mln so‘mgacha',
    'pricing.business.cta': '7 kun bepul sinab ko‘rish',

    'pricing.enterprise.name': 'Korporativ',
    'pricing.enterprise.price': 'Maxsus',
    'pricing.enterprise.desc': 'Yirik tashkilotlar va ishlab chiqaruvchilar uchun.',
    'pricing.enterprise.f1': 'Shaxsiy menejer (24/7)',
    'pricing.enterprise.f2': 'API integratsiya (1C, ERP)',
    'pricing.enterprise.f3': 'SLA 99.9% kafolat',
    'pricing.enterprise.f4': 'Maxsus haydovchilar parki',
    'pricing.enterprise.f5': 'Yuk sug‘urtasi cheksiz',
    'pricing.enterprise.cta': 'Bog‘lanish',

    // FAQ
    'faq.badge': 'Savol-javob',
    'faq.title': 'Tez-tez beriladigan savollar',
    'faq.q1.q': 'Cargo platformasi qanday ishlaydi?',
    'faq.q1.a':
      'Yuk yuboruvchi yangi so‘rov yaratadi. Tizim eng yaqin haydovchilarni topib taklif qiladi. Haydovchi qabul qilgach, real-time xaritada kuzatish boshlanadi.',
    'faq.q2.q': 'To‘lov qanday amalga oshiriladi?',
    'faq.q2.a':
      'Naqd, plastik karta yoki Cargo balansi orqali. Xizmat haqi haydovchining daromadidan avtomatik ushlab qolinadi.',
    'faq.q3.q': 'Haydovchi bo‘lib ro‘yxatdan o‘tish uchun nima kerak?',
    'faq.q3.a':
      'Pasport, haydovchilik guvohnomasi, avtomobil texpasporti va sug‘urta. Hujjatlar tasdiqlangach 24 soat ichida ishni boshlaysiz.',
    'faq.q4.q': 'MaterialMarket qanday farq qiladi?',
    'faq.q4.a':
      'MaterialMarket — qurilish materiallari uchun marketplace. Sotuvchilar va xaridorlarni to‘g‘ridan-to‘g‘ri bog‘laydi va Cargo logistikasidan foydalanadi.',
    'faq.q5.q': 'Yo‘qolgan yuk uchun kim javobgar?',
    'faq.q5.a':
      'Har bir yuk avtomatik sug‘urtalanadi. Yo‘qolish yoki shikastlanish hollarida 100% kompensatsiya beriladi.',
    'faq.q6.q': 'Ilovalar qaysi tillarda mavjud?',
    'faq.q6.a':
      'Hozirda O‘zbek va Rus tillari qo‘llab-quvvatlanadi. Yaqin orada Ingliz tili ham qo‘shiladi.',

    // Contact
    'contact.badge': 'Aloqa',
    'contact.title.a': 'Ariza qoldiring —',
    'contact.title.b': 'biz aloqaga chiqamiz',
    'contact.subtitle':
      'Savollaringiz bormi yoki Cargo bilan ishlashni xohlaysizmi? Quyidagi shaklni to‘ldiring.',
    'contact.phone': 'Telefon',
    'contact.email': 'Email',
    'contact.address': 'Manzil',
    'contact.addressVal': 'Toshkent, Yashnobod tumani, Mustaqillik 88',
    'contact.hours': 'Ish vaqti',
    'contact.hoursVal': '24/7 — har kuni',
    'contact.partnership': 'Hamkorlik',
    'contact.partnershipText':
      'Logistika kompaniyasi, online do‘kon yoki transport park egasimisiz? Maxsus shartlar uchun yozing.',
    'contact.f.name': 'Ism familiya',
    'contact.f.namePh': 'Ismingiz',
    'contact.f.phone': 'Telefon',
    'contact.f.email': 'Email (ixtiyoriy)',
    'contact.f.role': 'Kim sifatida murojaat qilyapsiz?',
    'contact.f.message': 'Xabar',
    'contact.f.messagePh': 'Qanday yordam bera olamiz?',
    'contact.submit': 'Arizani yuborish',
    'contact.sending': 'Yuborilmoqda...',
    'contact.done': 'Yuborildi — rahmat!',
    'contact.doneSub': '24 soat ichida siz bilan bog‘lanamiz.',
    'contact.terms': 'Yuborish orqali siz Foydalanish shartlari bilan rozisiz.',

    'role.sender': 'Yuk yuboruvchi',
    'role.driver': 'Haydovchi',
    'role.merchant': 'Sotuvchi (MaterialMarket)',
    'role.partner': 'Hamkor / korporativ mijoz',
    'role.other': 'Boshqa',

    // CTA
    'cta.title': 'Bugun birinchi yukingizni yuboring',
    'cta.subtitle': 'Ro‘yxatdan o‘ting va daqiqalar ichida haydovchi tayinlanadi.',
    'cta.send': 'Yuk yuborish',
    'cta.driver': 'Haydovchi sifatida ishlash',

    // Footer
    'footer.tagline':
      'O‘zbekistondagi yetakchi yuk yetkazib berish platformasi. Tezkor, ishonchli, qulay.',
    'footer.col.product': 'Mahsulot',
    'footer.col.company': 'Kompaniya',
    'footer.col.help': 'Yordam',
    'footer.product.features': 'Imkoniyatlar',
    'footer.product.pricing': 'Narxlar',
    'footer.product.apps': 'Mobil ilovalar',
    'footer.product.news': 'Yangiliklar',
    'footer.company.about': 'Biz haqimizda',
    'footer.company.career': 'Karyera',
    'footer.company.blog': 'Blog',
    'footer.company.partners': 'Hamkorlar',
    'footer.help.center': 'Yordam markazi',
    'footer.help.guide': 'Qo‘llanma',
    'footer.help.privacy': 'Maxfiylik siyosati',
    'footer.help.terms': 'Foydalanish shartlari',
    'footer.copy': 'Barcha huquqlar himoyalangan.',
    'footer.privacy': 'Maxfiylik',
    'footer.terms': 'Shartlar',
  },

  ru: {
    // Navbar
    'nav.features': 'Возможности',
    'nav.how': 'Как работает',
    'nav.apps': 'Приложения',
    'nav.pricing': 'Тарифы',
    'nav.faq': 'Вопросы',
    'nav.contact': 'Контакты',
    'nav.cta': 'Начать',

    // Hero
    'hero.badge': 'По всему Узбекистану — 24/7',
    'hero.title.a': 'Для вашего груза',
    'hero.title.b': 'ближайший водитель',
    'hero.title.c': 'в одно касание',
    'hero.subtitle':
      'Cargo — единая логистическая платформа, объединяющая отправителей и водителей. Быстрый заказ, отслеживание в реальном времени, надёжная оплата.',
    'hero.cta.start': 'Начать сейчас',
    'hero.cta.how': 'Как это работает',
    'hero.users': '10 000+ пользователей',
    'hero.usersSub': 'доверяют платформе',
    'hero.delivered': 'Доставлено',
    'hero.onTheWay': 'В пути',
    'hero.cargoCount': '12 грузов · 4 региона',

    // Stats
    'stats.users': 'Активных пользователей',
    'stats.drivers': 'Проверенных водителей',
    'stats.orders': 'Доставленных заказов',
    'stats.regions': 'Покрытие регионов',

    // Coverage
    'coverage.eyebrow': 'География покрытия',
    'coverage.title.a': 'По всему Узбекистану',
    'coverage.title.b': 'и за его пределами',
    'coverage.subtitle':
      'Доставляем грузы внутри города, между регионами и по международным направлениям.',
    'coverage.tab.regions': 'Междугород',
    'coverage.tab.cities': 'По городу',
    'coverage.tab.world': 'Международные',
    'coverage.note': 'Каждый день добавляем новые направления',

    // Features
    'features.badge': 'Возможности',
    'features.title.a': 'Логистику',
    'features.title.b': 'мы упростили',
    'features.subtitle': 'Несколько кликов — и ваш груз надёжно доставлен.',
    'features.f1.title': 'Быстрый поиск',
    'features.f1.desc': 'Подходящий водитель поблизости подбирается автоматически.',
    'features.f2.title': 'Отслеживание онлайн',
    'features.f2.desc': 'Где ваш груз — каждую секунду на карте.',
    'features.f3.title': 'Проверенные водители',
    'features.f3.desc': 'Документы и история вождения проверены.',
    'features.f4.title': 'Безопасная оплата',
    'features.f4.desc': 'Оплата напрямую через Click, Payme и Uzum.',
    'features.f5.title': 'Встроенный чат',
    'features.f5.desc': 'Прямая связь с водителем.',
    'features.f6.title': 'Оптимальный маршрут',
    'features.f6.desc': 'Рассчитываем самый короткий и дешёвый путь.',

    // Apps
    'apps.badge': 'Экосистема',
    'apps.title.a': 'Несколько',
    'apps.title.b': 'приложений',
    'apps.title.c': '— одна платформа',
    'apps.subtitle':
      'Отдельный опыт для каждой роли: отправитель, водитель, покупатель.',
    'apps.sender.name': 'Отправитель груза',
    'apps.sender.desc':
      'Для отправителей — мобильное приложение и веб-портал: заявки A→B, отслеживание в реальном времени.',
    'apps.driver.name': 'Водитель',
    'apps.driver.desc':
      'Приложение для водителей — онлайн режим, заказы, доход и баланс.',
    'apps.customer.name': 'Покупатель',
    'apps.customer.desc':
      'Для покупателей MaterialMarket — заказывайте стройматериалы онлайн.',

    // How it works
    'how.badge': 'Как работает',
    'how.title': '4 простых шага',
    'how.s1.title': 'Создайте заказ',
    'how.s1.desc': 'Укажите тип груза, вес и адрес. Цена рассчитывается автоматически.',
    'how.s2.title': 'Выберите водителя',
    'how.s2.desc': 'К вам направляется ближайший подходящий водитель.',
    'how.s3.title': 'Отслеживайте онлайн',
    'how.s3.desc': 'Смотрите местоположение груза на карте в реальном времени.',
    'how.s4.title': 'Оплатите и оцените',
    'how.s4.desc': 'После доставки — оплата и оценка водителя.',

    // Partners
    'partners.badge': 'Наши партнёры',
    'partners.title.a': 'Работаем с',
    'partners.title.b': 'ведущими производителями',
    'partners.title.c': 'и бизнесами',
    'partners.subtitle':
      'Крупнейшие заводы, производители и розничные сети Узбекистана доставляют свою продукцию через Cargo.',

    // Testimonials
    'testimonials.badge': 'Отзывы',
    'testimonials.title': 'Что говорят клиенты',
    'testimonials.subtitle': 'Тысячи водителей, бизнесов и покупателей доверяют нам.',
    'testimonials.q1.text':
      'Через Cargo получаю по 5–6 заказов в день. Доход вырос, баланс вывожу мгновенно.',
    'testimonials.q1.role': 'Водитель',
    'testimonials.q2.text':
      'Доставка товаров в регионы теперь занимает 2 минуты на оформление. Трекинг — супер.',
    'testimonials.q2.role': 'Маркетинг-менеджер',
    'testimonials.q3.text':
      'Через MaterialMarket купил цемент и кирпич напрямую с завода — на 30% дешевле.',
    'testimonials.q3.role': 'Строительная компания',

    // Pricing
    'pricing.badge': 'Тарифы',
    'pricing.title.a': 'Выберите подходящий',
    'pricing.title.b': 'тариф',
    'pricing.subtitle':
      'Во всех тарифах базовые функции включены. Без скрытых платежей — отмените в любое время.',
    'pricing.popular': 'ПОПУЛЯРНЫЙ',
    'pricing.perMonth': 'сум / мес',
    'pricing.note': '* Цены с НДС. При годовой оплате — 2 месяца БЕСПЛАТНО.',

    'pricing.starter.name': 'Стартовый',
    'pricing.starter.price': 'Бесплатно',
    'pricing.starter.desc': 'Для частных лиц и небольших отправлений.',
    'pricing.starter.f1': '5 заказов в месяц',
    'pricing.starter.f2': 'Базовый трекинг в реальном времени',
    'pricing.starter.f3': 'Поддержка по email',
    'pricing.starter.f4': 'Страховка груза до 5 млн сум',
    'pricing.starter.cta': 'Начать бесплатно',

    'pricing.business.name': 'Бизнес',
    'pricing.business.desc': 'Для растущих компаний и магазинов.',
    'pricing.business.f1': 'Безлимитные заказы',
    'pricing.business.f2': 'Карта в реальном времени + ETA',
    'pricing.business.f3': 'Выбор водителя',
    'pricing.business.f4': 'История, отчёты и аналитика',
    'pricing.business.f5': 'Telegram + SMS + Email уведомления',
    'pricing.business.f6': 'Страховка груза до 50 млн сум',
    'pricing.business.cta': 'Попробовать 7 дней бесплатно',

    'pricing.enterprise.name': 'Корпоративный',
    'pricing.enterprise.price': 'Индивид.',
    'pricing.enterprise.desc': 'Для крупных компаний и производителей.',
    'pricing.enterprise.f1': 'Персональный менеджер 24/7',
    'pricing.enterprise.f2': 'API интеграция (1C, ERP)',
    'pricing.enterprise.f3': 'SLA 99.9% гарантия',
    'pricing.enterprise.f4': 'Выделенный автопарк',
    'pricing.enterprise.f5': 'Безлимитная страховка груза',
    'pricing.enterprise.cta': 'Связаться',

    // FAQ
    'faq.badge': 'Вопросы',
    'faq.title': 'Часто задаваемые вопросы',
    'faq.q1.q': 'Как работает платформа Cargo?',
    'faq.q1.a':
      'Отправитель создаёт заявку. Система находит ближайших водителей и предлагает их. После принятия начинается отслеживание в реальном времени.',
    'faq.q2.q': 'Как происходит оплата?',
    'faq.q2.a':
      'Наличными, картой или с баланса Cargo. Комиссия автоматически удерживается из дохода водителя.',
    'faq.q3.q': 'Что нужно для регистрации водителя?',
    'faq.q3.a':
      'Паспорт, водительское удостоверение, техпаспорт и страховка. После проверки документов вы начнёте работу в течение 24 часов.',
    'faq.q4.q': 'Чем отличается MaterialMarket?',
    'faq.q4.a':
      'MaterialMarket — маркетплейс стройматериалов. Связывает продавцов и покупателей напрямую и использует логистику Cargo.',
    'faq.q5.q': 'Кто отвечает за утерянный груз?',
    'faq.q5.a':
      'Каждый груз автоматически застрахован. При утере или повреждении — 100% компенсация.',
    'faq.q6.q': 'На каких языках доступны приложения?',
    'faq.q6.a':
      'Сейчас поддерживаются узбекский и русский. В ближайшее время добавим английский.',

    // Contact
    'contact.badge': 'Контакты',
    'contact.title.a': 'Оставьте заявку —',
    'contact.title.b': 'мы свяжемся с вами',
    'contact.subtitle':
      'Есть вопросы или хотите работать с Cargo? Заполните форму ниже.',
    'contact.phone': 'Телефон',
    'contact.email': 'Email',
    'contact.address': 'Адрес',
    'contact.addressVal': 'Ташкент, Яшнабадский район, Мустакиллик 88',
    'contact.hours': 'Часы работы',
    'contact.hoursVal': '24/7 — ежедневно',
    'contact.partnership': 'Партнёрство',
    'contact.partnershipText':
      'Логистическая компания, интернет-магазин или владелец автопарка? Напишите для специальных условий.',
    'contact.f.name': 'Имя и фамилия',
    'contact.f.namePh': 'Ваше имя',
    'contact.f.phone': 'Телефон',
    'contact.f.email': 'Email (необязательно)',
    'contact.f.role': 'В качестве кого обращаетесь?',
    'contact.f.message': 'Сообщение',
    'contact.f.messagePh': 'Чем мы можем помочь?',
    'contact.submit': 'Отправить заявку',
    'contact.sending': 'Отправляется...',
    'contact.done': 'Отправлено — спасибо!',
    'contact.doneSub': 'Мы свяжемся с вами в течение 24 часов.',
    'contact.terms': 'Отправляя, вы соглашаетесь с Условиями использования.',

    'role.sender': 'Отправитель груза',
    'role.driver': 'Водитель',
    'role.merchant': 'Продавец (MaterialMarket)',
    'role.partner': 'Партнёр / корп. клиент',
    'role.other': 'Другое',

    // CTA
    'cta.title': 'Отправьте свой первый груз сегодня',
    'cta.subtitle': 'Зарегистрируйтесь и водитель будет назначен за минуты.',
    'cta.send': 'Отправить груз',
    'cta.driver': 'Стать водителем',

    // Footer
    'footer.tagline':
      'Ведущая платформа доставки грузов в Узбекистане. Быстро, надёжно, удобно.',
    'footer.col.product': 'Продукт',
    'footer.col.company': 'Компания',
    'footer.col.help': 'Помощь',
    'footer.product.features': 'Возможности',
    'footer.product.pricing': 'Цены',
    'footer.product.apps': 'Мобильные приложения',
    'footer.product.news': 'Новости',
    'footer.company.about': 'О нас',
    'footer.company.career': 'Карьера',
    'footer.company.blog': 'Блог',
    'footer.company.partners': 'Партнёры',
    'footer.help.center': 'Центр помощи',
    'footer.help.guide': 'Руководство',
    'footer.help.privacy': 'Политика конфиденциальности',
    'footer.help.terms': 'Условия использования',
    'footer.copy': 'Все права защищены.',
    'footer.privacy': 'Конфиденциальность',
    'footer.terms': 'Условия',
  },
};

const LangCtx = createContext<{
  lang: Lang;
  setLang: (l: Lang) => void;
  t: (key: string) => string;
}>({ lang: 'uz', setLang: () => {}, t: (k) => k });

export function LangProvider({ children }: { children: ReactNode }) {
  const [lang, setLangState] = useState<Lang>(() => {
    const saved = typeof window !== 'undefined' ? localStorage.getItem('cargo.lang') : null;
    return (saved === 'ru' || saved === 'uz' ? saved : 'uz') as Lang;
  });

  useEffect(() => {
    document.documentElement.lang = lang;
  }, [lang]);

  const setLang = (l: Lang) => {
    setLangState(l);
    try {
      localStorage.setItem('cargo.lang', l);
    } catch {}
  };

  const t = (key: string) => DICT[lang][key] ?? DICT.uz[key] ?? key;

  return <LangCtx.Provider value={{ lang, setLang, t }}>{children}</LangCtx.Provider>;
}

export function useLang() {
  return useContext(LangCtx);
}

export function useT() {
  return useContext(LangCtx).t;
}
