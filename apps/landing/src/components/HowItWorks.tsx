import { motion } from 'framer-motion';
import { useT } from '../i18n';

export function HowItWorks() {
  const t = useT();
  const STEPS = [
    { n: '01', title: t('how.s1.title'), desc: t('how.s1.desc') },
    { n: '02', title: t('how.s2.title'), desc: t('how.s2.desc') },
    { n: '03', title: t('how.s3.title'), desc: t('how.s3.desc') },
    { n: '04', title: t('how.s4.title'), desc: t('how.s4.desc') },
  ];
  return (
    <section
      id="how"
      className="py-24 md:py-32 bg-gradient-to-b from-transparent via-brand-900/10 to-transparent"
    >
      <div className="max-w-7xl mx-auto px-6">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="text-center max-w-2xl mx-auto mb-16"
        >
          <span className="text-xs font-semibold tracking-wider uppercase text-brand-400">
            {t('how.badge')}
          </span>
          <h2 className="text-3xl md:text-5xl font-extrabold mt-3">{t('how.title')}</h2>
        </motion.div>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 relative">
          <div className="hidden lg:block absolute top-10 left-[12%] right-[12%] h-px bg-gradient-to-r from-transparent via-brand-500/40 to-transparent" />
          {STEPS.map((s, i) => (
            <motion.div
              key={s.n}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.1 }}
              className="relative bg-white/[0.04] border border-white/10 rounded-2xl p-6"
            >
              <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-brand-500 to-brand-700 grid place-items-center font-extrabold text-lg shadow-lg shadow-brand-500/30 mb-4">
                {s.n}
              </div>
              <h3 className="font-semibold text-lg">{s.title}</h3>
              <p className="text-sm text-slate-400 mt-2 leading-relaxed">{s.desc}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
