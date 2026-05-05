import { useLang } from '../i18n';
import { motion, AnimatePresence } from 'framer-motion';
import { ArrowDown2 } from 'iconsax-react';
import { useState, useEffect, useRef } from 'react';

function FlagUZ({ size = 16 }: { size?: number }) {
  return (
    <svg viewBox="0 0 24 16" width={size * 1.4} height={size} className="rounded-sm shadow-sm shrink-0">
      <rect width="24" height="16" fill="#fff" />
      <rect width="24" height="5" y="0" fill="#1eb53a" />
      <rect width="24" height="5" y="11" fill="#0099b5" />
      <rect width="24" height="0.5" y="5" fill="#ce1126" />
      <rect width="24" height="0.5" y="10.5" fill="#ce1126" />
      <circle cx="5" cy="3" r="1.6" fill="#fff" />
      <circle cx="5.6" cy="2.7" r="1.4" fill="#0099b5" />
    </svg>
  );
}
function FlagRU({ size = 16 }: { size?: number }) {
  return (
    <svg viewBox="0 0 24 16" width={size * 1.4} height={size} className="rounded-sm shadow-sm shrink-0">
      <rect width="24" height="5.34" y="0" fill="#fff" />
      <rect width="24" height="5.34" y="5.34" fill="#0039a6" />
      <rect width="24" height="5.34" y="10.66" fill="#d52b1e" />
    </svg>
  );
}

export function LangSwitcher({ compact = false }: { compact?: boolean }) {
  const { lang, setLang } = useLang();
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function onClick(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    }
    document.addEventListener('mousedown', onClick);
    return () => document.removeEventListener('mousedown', onClick);
  }, []);

  const langs: { code: 'uz' | 'ru'; flag: JSX.Element; label: string }[] = [
    { code: 'uz', flag: <FlagUZ size={compact ? 14 : 16} />, label: "O‘zbek" },
    { code: 'ru', flag: <FlagRU size={compact ? 14 : 16} />, label: 'Русский' },
  ];
  const current = langs.find((l) => l.code === lang)!;

  return (
    <div ref={ref} className="relative">
      <button
        onClick={() => setOpen((o) => !o)}
        className={`inline-flex items-center gap-2 rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 transition ${
          compact ? 'px-2.5 py-1.5 text-xs' : 'px-3 py-2 text-sm'
        }`}
      >
        {current.flag}
        <span className="font-semibold uppercase">{current.code}</span>
        <ArrowDown2 size={12} className={`transition ${open ? 'rotate-180' : ''}`} />
      </button>
      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0, y: -6, scale: 0.98 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -6, scale: 0.98 }}
            transition={{ duration: 0.15 }}
            className="absolute right-0 top-full mt-2 min-w-[170px] bg-slate-900/95 backdrop-blur-xl border border-white/10 rounded-xl shadow-2xl overflow-hidden z-50"
          >
            {langs.map((l) => (
              <button
                key={l.code}
                onClick={() => {
                  setLang(l.code);
                  setOpen(false);
                }}
                className={`w-full flex items-center gap-2.5 px-3.5 py-2.5 text-sm transition ${
                  l.code === lang
                    ? 'bg-brand-500/15 text-brand-300'
                    : 'text-slate-200 hover:bg-white/5'
                }`}
              >
                {l.flag}
                <span className="font-medium">{l.label}</span>
                {l.code === lang && (
                  <span className="ml-auto w-1.5 h-1.5 rounded-full bg-brand-400" />
                )}
              </button>
            ))}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
