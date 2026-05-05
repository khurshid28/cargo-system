import { motion, useInView, useMotionValue, useTransform, animate } from 'framer-motion';
import { useEffect, useRef } from 'react';
import { useT } from '../i18n';

type Stat = { value: number; suffix?: string; format?: 'comma' | 'k' | 'plain'; label: string };

function CountUp({
  value,
  suffix = '',
  format = 'plain',
  inView,
}: {
  value: number;
  suffix?: string;
  format?: Stat['format'];
  inView: boolean;
}) {
  const mv = useMotionValue(0);
  const display = useTransform(mv, (latest) => {
    const n = Math.round(latest);
    if (format === 'comma') return n.toLocaleString('en-US');
    if (format === 'k') {
      if (n >= 1000) {
        const k = n / 1000;
        return `${k % 1 === 0 ? k.toFixed(0) : k.toFixed(1)}K`;
      }
      return String(n);
    }
    return String(n);
  });

  useEffect(() => {
    if (!inView) return;
    const controls = animate(mv, value, {
      duration: 2.2,
      ease: [0.22, 1, 0.36, 1],
    });
    return controls.stop;
  }, [inView, value, mv]);

  return (
    <span className="tabular-nums">
      <motion.span>{display}</motion.span>
      {suffix}
    </span>
  );
}

export function Stats() {
  const t = useT();
  const ref = useRef<HTMLDivElement>(null);
  const inView = useInView(ref, { once: true, margin: '-80px' });

  const STATS: Stat[] = [
    { value: 10000, suffix: '+', format: 'k',     label: t('stats.users') },
    { value: 2500,  suffix: '+', format: 'comma', label: t('stats.drivers') },
    { value: 50000, suffix: '+', format: 'k',     label: t('stats.orders') },
    { value: 14,    suffix: '',  format: 'plain', label: t('stats.regions') },
  ];

  return (
    <section id="stats" className="py-20 border-y border-white/5 bg-white/[0.02]">
      <div
        ref={ref}
        className="max-w-7xl mx-auto px-6 grid grid-cols-2 md:grid-cols-4 gap-8"
      >
        {STATS.map((s, i) => (
          <motion.div
            key={s.label}
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: i * 0.08 }}
            className="text-center"
          >
            <div className="text-4xl md:text-5xl font-extrabold bg-gradient-to-br from-white to-brand-300 bg-clip-text text-transparent">
              <CountUp value={s.value} suffix={s.suffix} format={s.format} inView={inView} />
            </div>
            <div className="mt-2 text-sm text-slate-400">{s.label}</div>
          </motion.div>
        ))}
      </div>
    </section>
  );
}
