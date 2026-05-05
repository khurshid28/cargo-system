import { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  HambergerMenu,
  CloseSquare,
  Element4,
  Routing2,
  MobileProgramming,
  DollarCircle,
  MessageQuestion,
  Call,
  ArrowRight,
} from 'iconsax-react';
import { Logo } from './Logo';
import { useT } from '../i18n';
import { LangSwitcher } from './LangSwitcher';

const LINKS = [
  { href: '#features', key: 'nav.features', Icon: Element4 },
  { href: '#how',      key: 'nav.how',      Icon: Routing2 },
  { href: '#apps',     key: 'nav.apps',     Icon: MobileProgramming },
  { href: '#pricing',  key: 'nav.pricing',  Icon: DollarCircle },
  { href: '#faq',      key: 'nav.faq',      Icon: MessageQuestion },
  { href: '#contact',  key: 'nav.contact',  Icon: Call },
];

export function Navbar() {
  const t = useT();
  const [scrolled, setScrolled] = useState(false);
  const [open, setOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20);
    onScroll();
    window.addEventListener('scroll', onScroll);
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  useEffect(() => {
    if (open) {
      const prev = document.body.style.overflow;
      document.body.style.overflow = 'hidden';
      return () => {
        document.body.style.overflow = prev;
      };
    }
  }, [open]);

  return (
    <motion.header
      initial={{ y: -80, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.5, ease: 'easeOut' }}
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        scrolled
          ? 'bg-slate-950/80 backdrop-blur-lg border-b border-white/5 py-3'
          : 'bg-transparent py-5'
      }`}
    >
      <div className="max-w-7xl mx-auto px-5 sm:px-6 flex items-center justify-between">
        <a href="#" className="flex items-center gap-2.5 group">
          <Logo className="h-9 w-9 sm:h-10 sm:w-10" />
          <span className="text-lg sm:text-xl font-extrabold tracking-tight bg-gradient-to-r from-white to-slate-300 bg-clip-text text-transparent">
            Cargo
          </span>
        </a>

        <nav className="hidden md:flex items-center gap-8">
          {LINKS.map((l, i) => (
            <motion.a
              key={l.href}
              href={l.href}
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 + i * 0.05 }}
              className="text-sm text-slate-300 hover:text-white transition relative group"
            >
              {t(l.key)}
              <span className="absolute -bottom-1 left-0 w-0 h-0.5 bg-brand-500 transition-all group-hover:w-full" />
            </motion.a>
          ))}
        </nav>

        <div className="hidden md:flex items-center gap-3">
          <LangSwitcher />
          <motion.a
            whileHover={{ scale: 1.04 }}
            whileTap={{ scale: 0.96 }}
            href="#contact"
            className="text-sm font-medium bg-gradient-to-r from-brand-500 to-brand-700 text-white px-5 py-2.5 rounded-lg shadow-lg shadow-brand-500/20 hover:shadow-brand-500/40 transition-shadow"
          >
            {t('nav.cta')}
          </motion.a>
        </div>

        <div className="md:hidden flex items-center gap-1.5">
          <LangSwitcher compact />
          <button
            className="text-white w-10 h-10 grid place-items-center rounded-lg hover:bg-white/5 active:bg-white/10 transition"
            onClick={() => setOpen((v) => !v)}
            aria-label="Menu"
          >
            <HambergerMenu size={24} />
          </button>
        </div>
      </div>

      {/* Mobile drawer */}
      <AnimatePresence>
        {open && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.25 }}
              onClick={() => setOpen(false)}
              className="md:hidden fixed inset-0 z-[60] bg-slate-950/70 backdrop-blur-sm"
            />
            <motion.aside
              initial={{ x: '100%' }}
              animate={{ x: 0 }}
              exit={{ x: '100%' }}
              transition={{ type: 'spring', damping: 28, stiffness: 280 }}
              className="md:hidden fixed top-0 right-0 bottom-0 z-[70] w-[85vw] max-w-sm bg-gradient-to-b from-slate-950 to-slate-900 border-l border-white/10 shadow-2xl flex flex-col"
            >
              {/* header */}
              <div className="flex items-center justify-between px-5 py-4 border-b border-white/5">
                <div className="flex items-center gap-2.5">
                  <Logo className="h-9 w-9" />
                  <span className="text-lg font-extrabold bg-gradient-to-r from-white to-slate-300 bg-clip-text text-transparent">
                    Cargo
                  </span>
                </div>
                <button
                  onClick={() => setOpen(false)}
                  className="w-10 h-10 grid place-items-center rounded-lg text-slate-300 hover:bg-white/5 active:bg-white/10 transition"
                  aria-label="Close"
                >
                  <CloseSquare size={24} />
                </button>
              </div>

              {/* links */}
              <nav className="flex-1 overflow-y-auto px-3 py-4">
                <div className="flex flex-col gap-1">
                  {LINKS.map((l, i) => (
                    <motion.a
                      key={l.href}
                      href={l.href}
                      onClick={() => setOpen(false)}
                      initial={{ opacity: 0, x: 20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 0.05 + i * 0.04 }}
                      className="flex items-center gap-3 px-3 py-3.5 rounded-xl text-slate-200 hover:bg-white/5 active:bg-white/10 transition group"
                    >
                      <span className="w-9 h-9 grid place-items-center rounded-lg bg-brand-500/10 text-brand-400 group-hover:bg-brand-500/20 transition">
                        <l.Icon size={20} variant="Bulk" />
                      </span>
                      <span className="text-[15px] font-medium flex-1">{t(l.key)}</span>
                      <ArrowRight size={16} className="text-slate-500 group-hover:text-brand-400 transition" />
                    </motion.a>
                  ))}
                </div>
              </nav>

              {/* footer */}
              <div className="px-5 py-4 border-t border-white/5 space-y-3">
                <a
                  href="#contact"
                  onClick={() => setOpen(false)}
                  className="flex items-center justify-center gap-2 bg-gradient-to-r from-brand-500 to-brand-700 text-white px-5 py-3.5 rounded-xl font-semibold shadow-lg shadow-brand-500/25 active:scale-[0.98] transition"
                >
                  {t('nav.cta')} <ArrowRight size={18} />
                </a>
                <div className="text-center text-[11px] text-slate-500">
                  © {new Date().getFullYear()} Cargo Logistics
                </div>
              </div>
            </motion.aside>
          </>
        )}
      </AnimatePresence>
    </motion.header>
  );
}
