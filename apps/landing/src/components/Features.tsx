import { motion } from 'framer-motion';
import { Truck, Map1, ShieldTick, Card, MessageText, Routing2 } from 'iconsax-react';
import { useT } from '../i18n';

export function Features() {
  const t = useT();
  const FEATURES = [
    { Icon: Truck, title: t('features.f1.title'), desc: t('features.f1.desc') },
    { Icon: Map1, title: t('features.f2.title'), desc: t('features.f2.desc') },
    { Icon: ShieldTick, title: t('features.f3.title'), desc: t('features.f3.desc') },
    { Icon: Card, title: t('features.f4.title'), desc: t('features.f4.desc') },
    { Icon: MessageText, title: t('features.f5.title'), desc: t('features.f5.desc') },
    { Icon: Routing2, title: t('features.f6.title'), desc: t('features.f6.desc') },
  ];
  return (
    <section id="features" className="py-24 md:py-32">
      <div className="max-w-7xl mx-auto px-6">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="text-center max-w-2xl mx-auto mb-16"
        >
          <span className="text-xs font-semibold tracking-wider uppercase text-brand-400">
            {t('features.badge')}
          </span>
          <h2 className="text-3xl md:text-5xl font-extrabold mt-3 leading-tight">
            {t('features.title.a')}{' '}
            <span className="bg-gradient-to-r from-brand-300 to-brand-500 bg-clip-text text-transparent">
              {t('features.title.b')}
            </span>
          </h2>
          <p className="mt-4 text-slate-400">{t('features.subtitle')}</p>
        </motion.div>

        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {FEATURES.map((f, i) => (
            <motion.div
              key={f.title}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.06 }}
              whileHover={{ y: -6 }}
              className="group relative bg-white/[0.03] border border-white/10 rounded-2xl p-6 hover:bg-white/[0.06] transition-all"
            >
              <div className="absolute -inset-px rounded-2xl opacity-0 group-hover:opacity-100 transition bg-gradient-to-br from-brand-500/30 to-transparent -z-10" />
              <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-brand-500/20 to-brand-700/20 border border-brand-500/30 grid place-items-center mb-4 text-brand-300 group-hover:text-white transition">
                <f.Icon size={24} variant="Bold" />
              </div>
              <h3 className="text-lg font-semibold">{f.title}</h3>
              <p className="mt-2 text-sm text-slate-400 leading-relaxed">{f.desc}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
