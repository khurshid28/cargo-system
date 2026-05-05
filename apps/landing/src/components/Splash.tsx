import { useEffect, useRef, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Truck } from 'iconsax-react';
import { Logo } from './Logo';

const DURATION_MS = 4000;

export function Splash() {
  const [show, setShow] = useState(true);
  const roadRef = useRef<HTMLDivElement>(null);
  const [travel, setTravel] = useState(180);

  useEffect(() => {
    const measure = () => {
      const w = roadRef.current?.offsetWidth ?? 256;
      // garage occupies right ~44px; truck width ~28px, hide ~10px past door
      setTravel(Math.max(40, w - 44 - 18));
    };
    measure();
    window.addEventListener('resize', measure);
    return () => window.removeEventListener('resize', measure);
  }, []);

  useEffect(() => {
    document.body.style.overflow = 'hidden';
    const t = setTimeout(() => setShow(false), DURATION_MS);
    return () => clearTimeout(t);
  }, []);

  useEffect(() => {
    if (!show) {
      const t = setTimeout(() => {
        document.body.style.overflow = '';
      }, 700);
      return () => clearTimeout(t);
    }
  }, [show]);

  const orbitDots = Array.from({ length: 12 });

  return (
    <AnimatePresence>
      {show && (
        <motion.div
          initial={{ opacity: 1 }}
          exit={{ opacity: 0, scale: 1.04, filter: 'blur(8px)' }}
          transition={{ duration: 0.7, ease: [0.4, 0, 0.2, 1] }}
          className="fixed inset-0 z-[200] grid place-items-center bg-[#05070d] overflow-hidden"
        >
          {/* Grid background */}
          <div
            className="absolute inset-0 opacity-[0.07]"
            style={{
              backgroundImage:
                'linear-gradient(rgba(59,130,246,0.6) 1px, transparent 1px), linear-gradient(90deg, rgba(59,130,246,0.6) 1px, transparent 1px)',
              backgroundSize: '48px 48px',
              maskImage: 'radial-gradient(circle at 50% 50%, black 0%, transparent 75%)',
              WebkitMaskImage: 'radial-gradient(circle at 50% 50%, black 0%, transparent 75%)',
            }}
          />

          {/* Radial glow */}
          <motion.div
            initial={{ opacity: 0, scale: 0.4 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 1, ease: 'easeOut' }}
            className="absolute inset-0"
            style={{
              background:
                'radial-gradient(circle at 50% 50%, rgba(59,130,246,0.35) 0%, rgba(124,58,237,0.18) 30%, transparent 65%)',
            }}
          />

          {/* Floating blobs */}
          <motion.div
            animate={{ x: [0, 40, 0], y: [0, -30, 0] }}
            transition={{ duration: 6, repeat: Infinity, ease: 'easeInOut' }}
            className="absolute top-[20%] left-[15%] w-72 h-72 rounded-full bg-brand-500/30 blur-3xl"
          />
          <motion.div
            animate={{ x: [0, -50, 0], y: [0, 30, 0] }}
            transition={{ duration: 7, repeat: Infinity, ease: 'easeInOut' }}
            className="absolute bottom-[15%] right-[15%] w-80 h-80 rounded-full bg-purple-500/25 blur-3xl"
          />

          {/* Outer orbital ring with dots */}
          <motion.div
            initial={{ rotate: 0, opacity: 0 }}
            animate={{ rotate: 360, opacity: 1 }}
            transition={{
              rotate: { duration: 8, ease: 'linear', repeat: Infinity },
              opacity: { duration: 0.6 },
            }}
            className="absolute w-[420px] h-[420px] sm:w-[540px] sm:h-[540px] rounded-full border border-dashed border-brand-400/25"
          >
            {orbitDots.map((_, i) => {
              const angle = (i / orbitDots.length) * 360;
              return (
                <div
                  key={i}
                  className="absolute top-1/2 left-1/2 w-1.5 h-1.5 -ml-[3px] -mt-[3px] rounded-full bg-brand-400/70"
                  style={{
                    transform: `rotate(${angle}deg) translateY(-210px)`,
                    boxShadow: '0 0 8px rgba(96,165,250,0.9)',
                  }}
                />
              );
            })}
          </motion.div>

          {/* Middle counter-rotating ring */}
          <motion.div
            initial={{ rotate: 0 }}
            animate={{ rotate: -360 }}
            transition={{ duration: 5, ease: 'linear', repeat: Infinity }}
            className="absolute w-[310px] h-[310px] sm:w-[390px] sm:h-[390px] rounded-full border border-purple-400/20"
          >
            <div
              className="absolute -top-1 left-1/2 -translate-x-1/2 w-2 h-2 rounded-full bg-purple-400"
              style={{ boxShadow: '0 0 12px rgba(192,132,252,1)' }}
            />
            <div
              className="absolute -bottom-1 left-1/2 -translate-x-1/2 w-2 h-2 rounded-full bg-brand-400"
              style={{ boxShadow: '0 0 12px rgba(96,165,250,1)' }}
            />
          </motion.div>

          {/* Inner solid ring */}
          <motion.div
            initial={{ rotate: 0 }}
            animate={{ rotate: 360 }}
            transition={{ duration: 3.5, ease: 'linear', repeat: Infinity }}
            className="absolute w-[220px] h-[220px] sm:w-[280px] sm:h-[280px] rounded-full border-2 border-brand-500/40"
          />

          {/* Center */}
          <div className="relative flex flex-col items-center gap-6">
            <motion.div
              initial={{ scale: 0, rotate: -180, opacity: 0 }}
              animate={{ scale: 1, rotate: 0, opacity: 1 }}
              transition={{ type: 'spring', stiffness: 180, damping: 14, delay: 0.15 }}
              className="relative"
            >
              <motion.div
                animate={{ scale: [1, 1.5, 1], opacity: [0.5, 0, 0.5] }}
                transition={{ duration: 2, repeat: Infinity, ease: 'easeOut' }}
                className="absolute inset-0 rounded-2xl bg-brand-500/30 blur-xl"
              />
              <motion.div
                animate={{
                  boxShadow: [
                    '0 0 0px 0px rgba(59,130,246,0.5)',
                    '0 0 60px 12px rgba(59,130,246,0.6)',
                    '0 0 0px 0px rgba(59,130,246,0.5)',
                  ],
                }}
                transition={{ duration: 1.8, repeat: Infinity, ease: 'easeInOut' }}
                className="relative rounded-2xl bg-gradient-to-br from-brand-500/20 to-purple-500/20 p-3 backdrop-blur-sm border border-white/10"
              >
                <Logo className="w-16 h-16 sm:w-20 sm:h-20" />
              </motion.div>
            </motion.div>

            {/* Letter-by-letter reveal */}
            <div className="text-center">
              <div className="text-4xl sm:text-5xl font-extrabold tracking-tight flex justify-center gap-0.5 leading-[1.4] pb-2">
                {'Cargo'.split('').map((ch, i) => (
                  <motion.span
                    key={i}
                    initial={{ opacity: 0, y: 20, filter: 'blur(8px)' }}
                    animate={{ opacity: 1, y: 0, filter: 'blur(0px)' }}
                    transition={{
                      delay: 0.55 + i * 0.08,
                      duration: 0.5,
                      ease: [0.4, 0, 0.2, 1],
                    }}
                    className="inline-block bg-gradient-to-b from-white via-brand-100 to-brand-400 bg-clip-text text-transparent"
                    style={{ paddingBottom: '0.15em' }}
                  >
                    {ch}
                  </motion.span>
                ))}
              </div>
              <motion.div
                initial={{ opacity: 0, y: 8 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 1.05, duration: 0.5 }}
                className="flex items-center justify-center gap-3 mt-2"
              >
                <span className="h-px w-8 bg-gradient-to-r from-transparent to-brand-400/60" />
                <span className="text-[10px] sm:text-xs text-brand-200/90 tracking-[0.4em] uppercase font-semibold">
                  Tezkor&nbsp;·&nbsp;Ishonchli&nbsp;·&nbsp;Aqlli
                </span>
                <span className="h-px w-8 bg-gradient-to-l from-transparent to-brand-400/60" />
              </motion.div>
            </div>

            {/* Car driving on the road */}
            <motion.div
              ref={roadRef}
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.7, duration: 0.4 }}
              className="relative w-64 sm:w-80 h-16 mt-2"
            >
              {/* Road */}
              <div className="absolute left-0 right-0 bottom-1 h-[2px] rounded-full bg-gradient-to-r from-brand-500/10 via-brand-400/40 to-purple-500/10" />
              <motion.div
                animate={{ backgroundPositionX: ['0px', '-24px'] }}
                transition={{ duration: 0.6, repeat: Infinity, ease: 'linear' }}
                className="absolute left-0 right-[44px] bottom-[3px] h-[1px] opacity-60"
                style={{
                  backgroundImage:
                    'linear-gradient(to right, rgba(148,163,184,0.7) 60%, transparent 60%)',
                  backgroundSize: '12px 1px',
                  backgroundRepeat: 'repeat-x',
                }}
              />

              {/* Garage building */}
              <div className="absolute right-0 bottom-0 w-11 h-14">
                {/* Roof */}
                <div
                  className="absolute -top-1.5 -left-1 -right-1 h-3 rounded-t-md bg-gradient-to-b from-slate-700 to-slate-800 border-t border-x border-brand-400/30"
                  style={{ boxShadow: '0 -2px 8px rgba(96,165,250,0.25)' }}
                />
                {/* Sign on roof */}
                <motion.div
                  animate={{ opacity: [0.6, 1, 0.6] }}
                  transition={{ duration: 1.6, repeat: Infinity }}
                  className="absolute -top-[18px] left-1/2 -translate-x-1/2 text-[6px] font-extrabold tracking-[0.15em] text-brand-300"
                  style={{ textShadow: '0 0 6px rgba(96,165,250,0.9)' }}
                >
                  OMBOR
                </motion.div>
                {/* Checkered finish flag on top of garage */}
                <div className="absolute -top-[26px] -right-1 flex flex-col items-center">
                  <motion.svg
                    animate={{ rotate: [0, -10, 6, -4, 0] }}
                    transition={{ duration: 1.8, repeat: Infinity, ease: 'easeInOut' }}
                    style={{ originX: 0, originY: 1, filter: 'drop-shadow(0 0 4px rgba(255,255,255,0.5))' }}
                    width="14"
                    height="9"
                    viewBox="0 0 14 9"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <rect width="14" height="9" fill="#fff" />
                    <rect x="0" y="0" width="3.5" height="3" fill="#0f172a" />
                    <rect x="7" y="0" width="3.5" height="3" fill="#0f172a" />
                    <rect x="3.5" y="3" width="3.5" height="3" fill="#0f172a" />
                    <rect x="10.5" y="3" width="3.5" height="3" fill="#0f172a" />
                    <rect x="0" y="6" width="3.5" height="3" fill="#0f172a" />
                    <rect x="7" y="6" width="3.5" height="3" fill="#0f172a" />
                  </motion.svg>
                  <div className="w-px h-2 bg-slate-400/80" />
                </div>
                {/* Building body */}
                <div className="absolute inset-0 rounded-t-lg bg-gradient-to-b from-slate-800 via-slate-900 to-slate-950 border border-brand-400/30 overflow-hidden">
                  {/* small side windows (decoration) */}
                  <div className="absolute top-1.5 left-1 w-1 h-1 rounded-sm bg-brand-300/40" />
                  <div className="absolute top-1.5 right-1 w-1 h-1 rounded-sm bg-brand-300/40" />

                  {/* Garage doorway opening */}
                  <div
                    className="absolute left-1/2 -translate-x-1/2 bottom-0 w-8 h-10 rounded-t-md overflow-hidden"
                    style={{ background: 'linear-gradient(to bottom, #0a0f1f 0%, #050810 100%)' }}
                  >
                    {/* Inner glow appearing as car arrives */}
                    <motion.div
                      initial={{ opacity: 0 }}
                      animate={{ opacity: [0, 0, 0.9, 0.9, 0] }}
                      transition={{
                        duration: 4,
                        times: [0, 0.6, 0.78, 0.92, 1],
                        ease: 'easeInOut',
                      }}
                      className="absolute inset-0"
                      style={{
                        background:
                          'radial-gradient(ellipse at center bottom, rgba(147,197,253,0.95) 0%, rgba(96,165,250,0.5) 40%, transparent 75%)',
                      }}
                    />
                    {/* Roll-up door (slats) */}
                    <motion.div
                      initial={{ y: 0 }}
                      animate={{ y: ['0%', '0%', '-100%', '-100%', '0%'] }}
                      transition={{
                        duration: 4,
                        times: [0, 0.6, 0.75, 0.88, 1],
                        ease: [0.6, 0, 0.4, 1],
                      }}
                      className="absolute inset-0"
                      style={{
                        backgroundImage:
                          'repeating-linear-gradient(to bottom, #475569 0 2px, #334155 2px 3px, #1e293b 3px 4px)',
                        boxShadow: 'inset 0 0 4px rgba(0,0,0,0.6), 0 1px 2px rgba(0,0,0,0.5)',
                      }}
                    />
                    {/* Door bottom edge highlight */}
                    <motion.div
                      initial={{ y: 0 }}
                      animate={{ y: ['0%', '0%', '-100%', '-100%', '0%'] }}
                      transition={{
                        duration: 4,
                        times: [0, 0.6, 0.75, 0.88, 1],
                        ease: [0.6, 0, 0.4, 1],
                      }}
                      className="absolute left-0 right-0 bottom-0 h-[2px] bg-gradient-to-r from-brand-400/50 via-brand-300/80 to-brand-400/50"
                      style={{ boxShadow: '0 0 6px rgba(96,165,250,0.9)' }}
                    />
                  </div>
                </div>
              </div>

              {/* Car */}
              <motion.div
                initial={{ x: 0, opacity: 1 }}
                animate={{
                  x: [0, 0, travel, travel + 18],
                  opacity: [1, 1, 1, 0],
                }}
                transition={{
                  duration: 3.6,
                  delay: 0.3,
                  times: [0, 0.25, 0.88, 1],
                  ease: 'easeInOut',
                }}
                className="absolute left-0 bottom-1 z-20"
              >
                {/* shadow */}
                <motion.div
                  animate={{ scaleX: [1, 0.85, 1], opacity: [0.45, 0.3, 0.45] }}
                  transition={{ duration: 0.4, repeat: Infinity, ease: 'easeInOut' }}
                  className="absolute -bottom-1 left-1/2 -translate-x-1/2 w-7 h-1.5 rounded-full bg-brand-500/50 blur-sm"
                />
                {/* truck body with cargo inside */}
                <motion.div
                  animate={{ y: [0, -1.5, 0] }}
                  transition={{ duration: 0.35, repeat: Infinity, ease: 'easeInOut' }}
                  className="relative text-brand-300"
                  style={{ filter: 'drop-shadow(0 0 8px rgba(96,165,250,0.85))' }}
                >
                  <Truck size={28} variant="Bold" />
                  {/* cargo box dropped INSIDE the truck container area */}
                  <motion.div
                    initial={{ y: -28, opacity: 0, rotate: -10 }}
                    animate={{
                      y: [-28, -2, 1, 0],
                      opacity: [0, 1, 1, 1],
                      rotate: [-10, 0, 0, 0],
                    }}
                    transition={{
                      duration: 0.85,
                      delay: 0.5,
                      times: [0, 0.6, 0.82, 1],
                      ease: 'easeOut',
                    }}
                    className="absolute"
                    style={{ left: '5px', top: '5px' }}
                  >
                    <div
                      className="relative w-[9px] h-[8px] rounded-[2px] bg-gradient-to-br from-amber-300 to-amber-600 border border-amber-700/70"
                      style={{ boxShadow: '0 1px 2px rgba(0,0,0,0.5), 0 0 4px rgba(251,191,36,0.6)' }}
                    >
                      <div className="absolute left-1/2 -translate-x-1/2 top-0 bottom-0 w-px bg-amber-800/70" />
                      <div className="absolute top-1/2 -translate-y-1/2 left-0 right-0 h-px bg-amber-800/70" />
                    </div>
                  </motion.div>
                </motion.div>
              </motion.div>
            </motion.div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
