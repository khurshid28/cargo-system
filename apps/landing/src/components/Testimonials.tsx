import { motion } from 'framer-motion';
import { Star1 } from 'iconsax-react';
import { useT } from '../i18n';

export function Testimonials() {
  const t = useT();
  const QUOTES = [
    {
      name: 'Akmal Karimov',
      role: t('testimonials.q1.role'),
      text: t('testimonials.q1.text'),
      avatar: 'https://i.pravatar.cc/120?img=12',
      stars: 5,
    },
    {
      name: 'Dilnoza Saidova',
      role: t('testimonials.q2.role'),
      text: t('testimonials.q2.text'),
      avatar: 'https://i.pravatar.cc/120?img=47',
      stars: 5,
    },
    {
      name: 'Bekzod Yusupov',
      role: t('testimonials.q3.role'),
      text: t('testimonials.q3.text'),
      avatar: 'https://i.pravatar.cc/120?img=33',
      stars: 5,
    },
  ];

  return (
    <section id="testimonials" className="py-20 sm:py-24 px-5 sm:px-6">
      <div className="max-w-7xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="text-center mb-12 sm:mb-16"
        >
          <span className="inline-block px-3 py-1 rounded-full bg-amber-500/10 text-amber-400 text-[11px] sm:text-xs font-semibold uppercase tracking-wider mb-3">
            {t('testimonials.badge')}
          </span>
          <h2 className="text-3xl sm:text-4xl md:text-5xl font-extrabold mb-4">
            {t('testimonials.title')}
          </h2>
          <p className="text-slate-400 max-w-xl mx-auto text-sm sm:text-base">
            {t('testimonials.subtitle')}
          </p>
        </motion.div>

        <div className="grid md:grid-cols-3 gap-5 sm:gap-6">
          {QUOTES.map((q, i) => (
            <motion.div
              key={q.name}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.1 }}
              whileHover={{ y: -6 }}
              className="bg-gradient-to-br from-slate-900/80 to-slate-900/40 border border-white/10 rounded-3xl p-6 sm:p-7 backdrop-blur"
            >
              <div className="flex items-center gap-1 mb-4">
                {Array.from({ length: q.stars }).map((_, idx) => (
                  <Star1 key={idx} size={16} variant="Bold" className="text-amber-400" />
                ))}
              </div>
              <p className="text-slate-200 leading-relaxed mb-6">"{q.text}"</p>
              <div className="flex items-center gap-3">
                <img
                  src={q.avatar}
                  alt={q.name}
                  className="w-11 h-11 rounded-full ring-2 ring-brand-500/40"
                />
                <div>
                  <div className="font-semibold">{q.name}</div>
                  <div className="text-xs text-slate-400">{q.role}</div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
