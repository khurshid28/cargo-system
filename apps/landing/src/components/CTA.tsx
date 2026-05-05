import { motion } from 'framer-motion';
import { ArrowRight } from 'iconsax-react';
import { useT } from '../i18n';

export function CTA() {
  const t = useT();
  return (
    <section id="cta" className="py-20 sm:py-24 px-5 sm:px-6">
      <div className="max-w-5xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-brand-600 via-brand-700 to-brand-900 p-8 sm:p-10 md:p-16 text-center"
        >
          <div
            className="absolute inset-0 opacity-20"
            style={{
              backgroundImage:
                'radial-gradient(circle at 30% 20%, white 0%, transparent 30%), radial-gradient(circle at 70% 80%, white 0%, transparent 30%)',
            }}
          />
          <div className="relative">
            <h2 className="text-3xl md:text-5xl font-extrabold leading-tight">
              {t('cta.title')}
            </h2>
            <p className="mt-4 text-brand-100 max-w-xl mx-auto text-sm sm:text-base">
              {t('cta.subtitle')}
            </p>
            <div className="mt-8 flex flex-wrap gap-3 justify-center">
              <motion.a
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.97 }}
                href="#contact"
                className="inline-flex items-center gap-2 bg-white text-brand-700 font-semibold px-6 py-3.5 rounded-xl shadow-xl"
              >
                {t('cta.send')} <ArrowRight size={18} />
              </motion.a>
              <motion.a
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.97 }}
                href="#contact"
                className="inline-flex items-center gap-2 bg-white/10 hover:bg-white/20 border border-white/30 backdrop-blur text-white font-semibold px-6 py-3.5 rounded-xl"
              >
                {t('cta.driver')}
              </motion.a>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
