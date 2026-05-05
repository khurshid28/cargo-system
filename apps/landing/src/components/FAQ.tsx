import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ArrowDown2 } from 'iconsax-react';
import { useT } from '../i18n';

export function FAQ() {
  const t = useT();
  const [open, setOpen] = useState<number | null>(0);
  const FAQS = [
    { q: t('faq.q1.q'), a: t('faq.q1.a') },
    { q: t('faq.q2.q'), a: t('faq.q2.a') },
    { q: t('faq.q3.q'), a: t('faq.q3.a') },
    { q: t('faq.q4.q'), a: t('faq.q4.a') },
    { q: t('faq.q5.q'), a: t('faq.q5.a') },
    { q: t('faq.q6.q'), a: t('faq.q6.a') },
  ];

  return (
    <section id="faq" className="py-20 sm:py-24 px-5 sm:px-6">
      <div className="max-w-4xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="text-center mb-10 sm:mb-12"
        >
          <span className="inline-block px-3 py-1 rounded-full bg-purple-500/10 text-purple-400 text-[11px] sm:text-xs font-semibold uppercase tracking-wider mb-3">
            {t('faq.badge')}
          </span>
          <h2 className="text-3xl sm:text-4xl md:text-5xl font-extrabold mb-4">
            {t('faq.title')}
          </h2>
        </motion.div>

        <div className="space-y-3">
          {FAQS.map((f, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 12 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.05 }}
              className="bg-slate-900/60 border border-white/10 rounded-2xl overflow-hidden"
            >
              <button
                onClick={() => setOpen(open === i ? null : i)}
                className="w-full flex items-center justify-between text-left p-5 hover:bg-white/5 transition"
              >
                <span className="font-semibold pr-4">{f.q}</span>
                <motion.div animate={{ rotate: open === i ? 180 : 0 }}>
                  <ArrowDown2 size={20} className="text-brand-400 shrink-0" />
                </motion.div>
              </button>
              <AnimatePresence initial={false}>
                {open === i && (
                  <motion.div
                    initial={{ height: 0, opacity: 0 }}
                    animate={{ height: 'auto', opacity: 1 }}
                    exit={{ height: 0, opacity: 0 }}
                    transition={{ duration: 0.25 }}
                  >
                    <div className="px-5 pb-5 text-slate-400 leading-relaxed">{f.a}</div>
                  </motion.div>
                )}
              </AnimatePresence>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
