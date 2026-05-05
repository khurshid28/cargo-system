import { motion } from 'framer-motion';
import { ArrowRight, PlayCircle } from 'iconsax-react';
import { useT } from '../i18n';

const HERO_IMG =
  'https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?auto=format&fit=crop&w=1400&q=80';

export function Hero() {
  const t = useT();
  return (
    <section className="relative pt-28 pb-16 md:pt-44 md:pb-32 overflow-hidden">
      <div
        className="absolute inset-0 -z-10 opacity-30 animate-gradient-x"
        style={{
          backgroundImage:
            'radial-gradient(circle at 20% 20%, #1f49f5 0%, transparent 40%), radial-gradient(circle at 80% 60%, #19308c 0%, transparent 45%), radial-gradient(circle at 50% 90%, #3367ff 0%, transparent 40%)',
          backgroundSize: '200% 200%',
        }}
      />
      <div className="absolute inset-0 -z-10 bg-[linear-gradient(to_bottom,transparent,rgba(2,6,23,0.9))]" />

      <div className="max-w-7xl mx-auto px-5 sm:px-6 grid md:grid-cols-2 gap-10 md:gap-14 items-center">
        <div>
          <motion.span
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="inline-flex items-center gap-2 text-xs font-medium bg-white/5 border border-white/10 text-brand-200 px-3 py-1.5 rounded-full mb-6"
          >
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
            {t('hero.badge')}
          </motion.span>

          <motion.h1
            initial={{ opacity: 0, y: 24 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.15 }}
            className="text-[2.1rem] sm:text-5xl md:text-6xl font-extrabold tracking-tight leading-[1.08]"
          >
            {t('hero.title.a')}{' '}
            <span className="bg-gradient-to-r from-brand-300 via-brand-400 to-brand-600 bg-clip-text text-transparent">
              {t('hero.title.b')}
            </span>{' '}
            {t('hero.title.c')}
          </motion.h1>

          <motion.p
            initial={{ opacity: 0, y: 24 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.3 }}
            className="mt-5 text-base md:text-lg text-slate-300 max-w-xl"
          >
            {t('hero.subtitle')}
          </motion.p>

          <motion.div
            initial={{ opacity: 0, y: 24 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.45 }}
            className="mt-8 flex flex-wrap gap-3"
          >
            <motion.a
              whileHover={{ scale: 1.04 }}
              whileTap={{ scale: 0.97 }}
              href="#contact"
              className="inline-flex items-center gap-2 bg-gradient-to-r from-brand-500 to-brand-700 text-white px-6 py-3.5 rounded-xl font-medium shadow-lg shadow-brand-500/30"
            >
              {t('hero.cta.start')} <ArrowRight size={18} />
            </motion.a>
            <motion.a
              whileHover={{ scale: 1.04 }}
              whileTap={{ scale: 0.97 }}
              href="#how"
              className="inline-flex items-center gap-2 bg-white/5 hover:bg-white/10 border border-white/10 text-white px-6 py-3.5 rounded-xl font-medium"
            >
              <PlayCircle size={18} variant="Bold" /> {t('hero.cta.how')}
            </motion.a>
          </motion.div>

          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.7 }}
            className="mt-10 flex items-center gap-6 text-sm text-slate-400"
          >
            <div className="flex -space-x-2">
              {[1, 2, 3, 4].map((i) => (
                <img
                  key={i}
                  src={`https://i.pravatar.cc/40?img=${i + 10}`}
                  alt=""
                  className="w-8 h-8 rounded-full border-2 border-slate-950"
                />
              ))}
            </div>
            <div>
              <div className="text-white font-semibold">{t('hero.users')}</div>
              <div className="text-xs">{t('hero.usersSub')}</div>
            </div>
          </motion.div>
        </div>

        <motion.div
          initial={{ opacity: 0, scale: 0.9, rotate: 4 }}
          animate={{ opacity: 1, scale: 1, rotate: 0 }}
          transition={{ duration: 0.8, delay: 0.2, type: 'spring' }}
          className="relative px-2 sm:px-0"
        >
          <div className="absolute -inset-4 bg-gradient-to-r from-brand-500/30 to-purple-500/30 blur-3xl rounded-3xl" />
          <motion.img
            src={HERO_IMG}
            alt="Cargo truck"
            className="relative rounded-3xl shadow-2xl w-full object-cover h-[300px] sm:h-[420px] md:h-[520px] animate-float"
            loading="eager"
          />
          <motion.div
            initial={{ opacity: 0, x: -30 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.9 }}
            className="absolute left-2 sm:-left-4 top-4 sm:top-10 bg-white text-slate-900 rounded-2xl p-3 sm:p-4 shadow-xl w-44 sm:w-56"
          >
            <div className="flex items-center gap-2.5 sm:gap-3">
              <div className="w-9 h-9 sm:w-10 sm:h-10 rounded-full bg-emerald-100 grid place-items-center shrink-0">
                <span className="text-emerald-600 text-lg sm:text-xl">✓</span>
              </div>
              <div className="min-w-0">
                <div className="text-[10px] sm:text-xs text-slate-500">{t('hero.delivered')}</div>
                <div className="font-semibold text-xs sm:text-sm truncate">Toshkent → Samarqand</div>
              </div>
            </div>
          </motion.div>
          <motion.div
            initial={{ opacity: 0, x: 30 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 1.1 }}
            className="absolute right-2 sm:-right-2 bottom-4 sm:bottom-10 bg-white text-slate-900 rounded-2xl p-3 sm:p-4 shadow-xl w-48 sm:w-60"
          >
            <div className="text-xs text-slate-500">{t('hero.onTheWay')}</div>
            <div className="font-semibold">{t('hero.cargoCount')}</div>
            <div className="mt-2 h-1.5 bg-slate-100 rounded-full overflow-hidden">
              <motion.div
                initial={{ width: 0 }}
                animate={{ width: '78%' }}
                transition={{ delay: 1.3, duration: 1.2 }}
                className="h-full bg-gradient-to-r from-brand-400 to-brand-600 rounded-full"
              />
            </div>
          </motion.div>
        </motion.div>
      </div>
    </section>
  );
}
