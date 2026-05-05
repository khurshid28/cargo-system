import { motion } from 'framer-motion';
import { Instagram, Facebook, Send2, Call, Sms, Location } from 'iconsax-react';
import { Logo } from './Logo';
import { useT } from '../i18n';

export function Footer() {
  const t = useT();
  const COLS = [
    {
      title: t('footer.col.product'),
      items: [
        t('footer.product.features'),
        t('footer.product.pricing'),
        t('footer.product.apps'),
        t('footer.product.news'),
      ],
    },
    {
      title: t('footer.col.company'),
      items: [
        t('footer.company.about'),
        t('footer.company.career'),
        t('footer.company.blog'),
        t('footer.company.partners'),
      ],
    },
    {
      title: t('footer.col.help'),
      items: [
        t('footer.help.center'),
        t('footer.help.guide'),
        t('footer.help.privacy'),
        t('footer.help.terms'),
      ],
    },
  ];
  return (
    <footer className="border-t border-white/5 bg-slate-950">
      <div className="max-w-7xl mx-auto px-5 sm:px-6 py-14 sm:py-16 grid md:grid-cols-2 lg:grid-cols-5 gap-10">
        <div className="lg:col-span-2">
          <div className="flex items-center gap-3">
            <Logo className="h-10 w-10" />
            <span className="text-xl font-extrabold">Cargo</span>
          </div>
          <p className="mt-4 text-sm text-slate-400 max-w-sm">{t('footer.tagline')}</p>
          <div className="mt-6 space-y-2 text-sm text-slate-400">
            <div className="flex items-center gap-3">
              <Call size={16} /> +998 95 064 28 27
            </div>
            <div className="flex items-center gap-3">
              <Sms size={16} /> hello@cargo.uz
            </div>
            <div className="flex items-center gap-3">
              <Location size={16} /> Toshkent, O‘zbekiston
            </div>
          </div>
          <div className="mt-6 flex gap-3">
            {[Instagram, Facebook, Send2].map((Icon, i) => (
              <motion.a
                key={i}
                whileHover={{ scale: 1.1, y: -2 }}
                whileTap={{ scale: 0.95 }}
                href="#"
                className="w-10 h-10 rounded-xl bg-white/5 hover:bg-brand-600 border border-white/10 grid place-items-center transition"
              >
                <Icon size={18} variant="Bold" />
              </motion.a>
            ))}
          </div>
        </div>

        {COLS.map((col, i) => (
          <motion.div
            key={col.title}
            initial={{ opacity: 0, y: 12 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: i * 0.06 }}
          >
            <div className="text-sm font-semibold text-white mb-4">{col.title}</div>
            <ul className="space-y-2 text-sm text-slate-400">
              {col.items.map((it) => (
                <li key={it}>
                  <a href="#" className="hover:text-white transition">
                    {it}
                  </a>
                </li>
              ))}
            </ul>
          </motion.div>
        ))}
      </div>

      <div className="border-t border-white/5">
        <div className="max-w-7xl mx-auto px-5 sm:px-6 py-6 flex flex-col md:flex-row gap-3 items-center justify-between text-xs text-slate-500">
          <div>
            © {new Date().getFullYear()} Cargo. {t('footer.copy')}
          </div>
          <div className="flex gap-6">
            <a href="#" className="hover:text-white">
              {t('footer.privacy')}
            </a>
            <a href="#" className="hover:text-white">
              {t('footer.terms')}
            </a>
            <a href="#" className="hover:text-white">
              Cookies
            </a>
          </div>
        </div>
      </div>
    </footer>
  );
}
