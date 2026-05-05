import { motion } from 'framer-motion';
import { TickCircle, Crown1, Flash, Buildings2, Box1 } from 'iconsax-react';
import { useT } from '../i18n';

export function Pricing() {
  const t = useT();

  const PLANS = [
    {
      name: t('pricing.starter.name'),
      icon: <Box1 size={22} variant="Bold" />,
      price: t('pricing.starter.price'),
      suffix: '',
      desc: t('pricing.starter.desc'),
      features: [
        t('pricing.starter.f1'),
        t('pricing.starter.f2'),
        t('pricing.starter.f3'),
        t('pricing.starter.f4'),
      ],
      cta: t('pricing.starter.cta'),
      highlight: false,
      tone: 'from-slate-500 to-slate-700',
    },
    {
      name: t('pricing.business.name'),
      icon: <Flash size={22} variant="Bold" />,
      price: '299 000',
      suffix: t('pricing.perMonth'),
      desc: t('pricing.business.desc'),
      features: [
        t('pricing.business.f1'),
        t('pricing.business.f2'),
        t('pricing.business.f3'),
        t('pricing.business.f4'),
        t('pricing.business.f5'),
        t('pricing.business.f6'),
      ],
      cta: t('pricing.business.cta'),
      highlight: true,
      tone: 'from-brand-500 to-brand-700',
    },
    {
      name: t('pricing.enterprise.name'),
      icon: <Buildings2 size={22} variant="Bold" />,
      price: t('pricing.enterprise.price'),
      suffix: '',
      desc: t('pricing.enterprise.desc'),
      features: [
        t('pricing.enterprise.f1'),
        t('pricing.enterprise.f2'),
        t('pricing.enterprise.f3'),
        t('pricing.enterprise.f4'),
        t('pricing.enterprise.f5'),
      ],
      cta: t('pricing.enterprise.cta'),
      highlight: false,
      tone: 'from-purple-500 to-pink-700',
    },
  ];

  return (
    <section id="pricing" className="py-20 sm:py-24 px-5 sm:px-6 relative">
      <div className="max-w-7xl mx-auto relative">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="text-center mb-12 sm:mb-16"
        >
          <span className="inline-block px-3 py-1 rounded-full bg-emerald-500/10 text-emerald-400 text-[11px] sm:text-xs font-semibold uppercase tracking-wider mb-3">
            {t('pricing.badge')}
          </span>
          <h2 className="text-3xl sm:text-4xl md:text-5xl font-extrabold mb-4 leading-tight">
            {t('pricing.title.a')}{' '}
            <span className="bg-gradient-to-r from-brand-400 to-brand-600 bg-clip-text text-transparent">
              {t('pricing.title.b')}
            </span>
          </h2>
          <p className="text-slate-400 text-sm sm:text-base max-w-xl mx-auto">
            {t('pricing.subtitle')}
          </p>
        </motion.div>

        <div className="grid md:grid-cols-3 gap-5 sm:gap-6">
          {PLANS.map((p, i) => (
            <motion.div
              key={p.name}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.1 }}
              whileHover={{ y: -6 }}
              className={`relative rounded-3xl p-6 sm:p-8 backdrop-blur ${
                p.highlight
                  ? 'bg-gradient-to-br from-brand-600/20 to-brand-900/20 border-2 border-brand-500/40 shadow-xl shadow-brand-500/10 md:scale-105'
                  : 'bg-slate-900/60 border border-white/10'
              }`}
            >
              {p.highlight && (
                <div className="absolute -top-3 left-1/2 -translate-x-1/2 bg-gradient-to-r from-brand-500 to-brand-700 text-white text-[10px] sm:text-xs font-bold px-3 py-1 rounded-full inline-flex items-center gap-1 whitespace-nowrap">
                  <Crown1 size={12} variant="Bold" /> {t('pricing.popular')}
                </div>
              )}
              <div className="flex items-center gap-3 mb-3">
                <div
                  className={`w-11 h-11 rounded-xl bg-gradient-to-br ${p.tone} grid place-items-center text-white`}
                >
                  {p.icon}
                </div>
                <h3 className="text-xl font-bold">{p.name}</h3>
              </div>
              <p className="text-slate-400 text-sm mb-5">{p.desc}</p>
              <div className="mb-6 flex items-baseline gap-2 flex-wrap">
                <span className="text-3xl sm:text-4xl font-extrabold">{p.price}</span>
                {p.suffix && <span className="text-slate-400 text-sm">{p.suffix}</span>}
              </div>
              <ul className="space-y-2.5 mb-7">
                {p.features.map((f) => (
                  <li
                    key={f}
                    className="flex items-start gap-2 text-sm text-slate-300"
                  >
                    <TickCircle
                      size={18}
                      variant="Bold"
                      className="text-brand-400 mt-0.5 shrink-0"
                    />
                    {f}
                  </li>
                ))}
              </ul>
              <a
                href="#contact"
                className={`block text-center py-3 rounded-xl font-semibold transition ${
                  p.highlight
                    ? 'bg-gradient-to-r from-brand-500 to-brand-700 text-white hover:shadow-lg hover:shadow-brand-500/30'
                    : 'bg-white/5 text-white border border-white/10 hover:bg-white/10'
                }`}
              >
                {p.cta}
              </a>
            </motion.div>
          ))}
        </div>

        <motion.p
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          className="text-center text-xs sm:text-sm text-slate-500 mt-8"
        >
          {t('pricing.note')}
        </motion.p>
      </div>
    </section>
  );
}
