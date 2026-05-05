import { motion } from 'framer-motion';
import { useState } from 'react';
import { Buildings2, Buliding, Global, Location, TickCircle, ArrowRight } from 'iconsax-react';
import { useT } from '../i18n';

type TabKey = 'regions' | 'cities' | 'world';

type Item = { name: string; sub?: string; code?: string };

// Inline SVG flags (simple stripes/blocks). 24x16 viewBox, rounded.
const FLAGS: Record<string, JSX.Element> = {
  RU: (
    <>
      <rect width="24" height="16" fill="#fff" />
      <rect y="5.33" width="24" height="5.34" fill="#0039A6" />
      <rect y="10.67" width="24" height="5.33" fill="#D52B1E" />
    </>
  ),
  KZ: (
    <>
      <rect width="24" height="16" fill="#00AFCA" />
      <circle cx="12" cy="8" r="2.4" fill="#FEC50C" />
      {[...Array(12)].map((_, i) => {
        const a = (i * Math.PI) / 6;
        return (
          <rect
            key={i}
            x="11.7"
            y="3.6"
            width="0.6"
            height="1.6"
            fill="#FEC50C"
            transform={`rotate(${(i * 30)} 12 8)`}
          />
        );
      })}
    </>
  ),
  KG: (
    <>
      <rect width="24" height="16" fill="#E8112D" />
      <circle cx="12" cy="8" r="2.6" fill="#FFEF00" />
      <circle cx="12" cy="8" r="1.4" fill="none" stroke="#E8112D" strokeWidth="0.4" />
    </>
  ),
  TJ: (
    <>
      <rect width="24" height="16" fill="#fff" />
      <rect width="24" height="4.6" fill="#CC0000" />
      <rect y="11.4" width="24" height="4.6" fill="#006600" />
      <circle cx="12" cy="8" r="1.1" fill="#F8C300" />
    </>
  ),
  TM: (
    <>
      <rect width="24" height="16" fill="#00853F" />
      <rect width="4.5" height="16" fill="#CA1F27" />
    </>
  ),
  TR: (
    <>
      <rect width="24" height="16" fill="#E30A17" />
      <circle cx="9" cy="8" r="3" fill="#fff" />
      <circle cx="9.8" cy="8" r="2.4" fill="#E30A17" />
      <polygon
        points="13,8 11.6,8.6 12.1,7.2 11,6.2 12.5,6.3 13,5 13.5,6.3 15,6.2 13.9,7.2 14.4,8.6"
        fill="#fff"
      />
    </>
  ),
  CN: (
    <>
      <rect width="24" height="16" fill="#DE2910" />
      <polygon points="4,2.4 4.6,4 6.3,4 4.95,5 5.5,6.6 4,5.6 2.5,6.6 3.05,5 1.7,4 3.4,4" fill="#FFDE00" />
      <circle cx="8" cy="2" r="0.5" fill="#FFDE00" />
      <circle cx="9.5" cy="3.5" r="0.5" fill="#FFDE00" />
      <circle cx="9.5" cy="5.5" r="0.5" fill="#FFDE00" />
      <circle cx="8" cy="7" r="0.5" fill="#FFDE00" />
    </>
  ),
  BY: (
    <>
      <rect width="24" height="16" fill="#fff" />
      <rect width="24" height="10.4" fill="#CE1720" />
      <rect y="10.4" width="24" height="5.6" fill="#4AA657" />
      <rect width="3" height="16" fill="#fff" />
    </>
  ),
};

const REGIONS: Item[] = [
  { name: 'Toshkent shahri', sub: 'Poytaxt' },
  { name: 'Toshkent viloyati', sub: 'Markaz' },
  { name: 'Samarqand', sub: 'Janubi-g‘arbiy' },
  { name: 'Buxoro', sub: 'G‘arbiy' },
  { name: 'Andijon', sub: 'Farg‘ona vodiysi' },
  { name: 'Farg‘ona', sub: 'Farg‘ona vodiysi' },
  { name: 'Namangan', sub: 'Farg‘ona vodiysi' },
  { name: 'Qashqadaryo', sub: 'Janub' },
  { name: 'Surxondaryo', sub: 'Janub' },
  { name: 'Jizzax', sub: 'Markaz' },
  { name: 'Sirdaryo', sub: 'Markaz' },
  { name: 'Navoiy', sub: 'Markaziy g‘arb' },
  { name: 'Xorazm', sub: 'Shimoli-g‘arbiy' },
  { name: 'Qoraqalpog‘iston', sub: 'Respublika' },
];

const CITIES: Item[] = [
  { name: 'Toshkent',  sub: 'Barcha tumanlar' },
  { name: 'Samarqand', sub: 'Markaz va atrof' },
  { name: 'Buxoro',    sub: 'Markaz va atrof' },
  { name: 'Andijon',   sub: 'Markaz va atrof' },
  { name: 'Namangan',  sub: 'Markaz va atrof' },
  { name: 'Farg‘ona',  sub: 'Markaz va atrof' },
  { name: 'Nukus',     sub: 'Markaz va atrof' },
  { name: 'Qarshi',    sub: 'Markaz va atrof' },
  { name: 'Termiz',    sub: 'Markaz va atrof' },
  { name: 'Urganch',   sub: 'Markaz va atrof' },
  { name: 'Jizzax',    sub: 'Markaz va atrof' },
  { name: 'Navoiy',    sub: 'Markaz va atrof' },
];

const WORLD: Item[] = [
  { name: 'Rossiya',      code: 'RU', sub: 'Moskva, S-Peterburg' },
  { name: 'Qozog‘iston',  code: 'KZ', sub: 'Almati, Astana' },
  { name: 'Qirg‘iziston', code: 'KG', sub: 'Bishkek, O‘sh' },
  { name: 'Tojikiston',   code: 'TJ', sub: 'Dushanbe, Xo‘jand' },
  { name: 'Turkmaniston', code: 'TM', sub: 'Ashxobod' },
  { name: 'Turkiya',      code: 'TR', sub: 'Istanbul, Ankara' },
  { name: 'Xitoy',        code: 'CN', sub: 'Urumchi, Pekin' },
  { name: 'Belarus',      code: 'BY', sub: 'Minsk' },
];

export function Coverage() {
  const t = useT();
  const [tab, setTab] = useState<TabKey>('regions');

  const TABS: { key: TabKey; label: string; Icon: typeof Buliding; count: number }[] = [
    { key: 'regions', label: t('coverage.tab.regions'), Icon: Buliding,   count: REGIONS.length },
    { key: 'cities',  label: t('coverage.tab.cities'),  Icon: Buildings2, count: CITIES.length },
    { key: 'world',   label: t('coverage.tab.world'),   Icon: Global,     count: WORLD.length },
  ];

  const items = tab === 'regions' ? REGIONS : tab === 'cities' ? CITIES : WORLD;

  return (
    <section id="coverage" className="py-20 sm:py-28 relative overflow-hidden">
      {/* Decorative blob */}
      <div className="pointer-events-none absolute inset-0 -z-0">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[700px] h-[700px] rounded-full bg-brand-500/[0.06] blur-[140px]" />
      </div>

      <div className="relative max-w-7xl mx-auto px-6">
        <div className="text-center mb-10 sm:mb-14">
          <motion.div
            initial={{ opacity: 0, y: 12 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-brand-500/10 border border-brand-400/20 text-brand-300 text-xs font-semibold tracking-wider uppercase"
          >
            <Location size={14} variant="Bold" />
            {t('coverage.eyebrow')}
          </motion.div>
          <motion.h2
            initial={{ opacity: 0, y: 14 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.05 }}
            className="mt-4 text-3xl sm:text-4xl md:text-5xl font-extrabold tracking-tight"
          >
            {t('coverage.title.a')}{' '}
            <span className="bg-gradient-to-r from-brand-300 via-brand-400 to-purple-400 bg-clip-text text-transparent">
              {t('coverage.title.b')}
            </span>
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 14 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.1 }}
            className="mt-3 text-slate-400 max-w-2xl mx-auto text-sm sm:text-base"
          >
            {t('coverage.subtitle')}
          </motion.p>
        </div>

        {/* Tabs */}
        <div className="flex flex-wrap justify-center gap-2 sm:gap-3 mb-10">
          {TABS.map(({ key, label, Icon, count }) => {
            const active = tab === key;
            return (
              <button
                key={key}
                onClick={() => setTab(key)}
                className={[
                  'group relative flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold transition-all',
                  active
                    ? 'bg-gradient-to-r from-brand-500 to-purple-500 text-white shadow-lg shadow-brand-500/25'
                    : 'bg-white/5 text-slate-300 border border-white/10 hover:bg-white/10 hover:text-white',
                ].join(' ')}
              >
                <Icon size={16} variant={active ? 'Bold' : 'Linear'} />
                <span>{label}</span>
                <span
                  className={[
                    'ml-1 inline-flex items-center justify-center min-w-[22px] h-5 px-1.5 rounded-full text-[11px] font-bold',
                    active ? 'bg-white/20 text-white' : 'bg-white/10 text-slate-400',
                  ].join(' ')}
                >
                  {count}
                </span>
              </button>
            );
          })}
        </div>

        {/* Items grid */}
        <motion.div
          key={tab}
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.35 }}
          className={[
            'grid gap-3',
            tab === 'world'
              ? 'grid-cols-1 sm:grid-cols-2 lg:grid-cols-4'
              : 'grid-cols-2 sm:grid-cols-3 lg:grid-cols-4',
          ].join(' ')}
        >
          {items.map((it, i) => (
            <motion.div
              key={`${tab}-${it.name}`}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.03, duration: 0.3 }}
              className="group relative flex items-center gap-3 px-3.5 py-3 rounded-2xl bg-gradient-to-br from-white/[0.04] to-white/[0.02] border border-white/10 hover:border-brand-400/40 hover:from-brand-500/[0.08] hover:to-purple-500/[0.05] transition-all"
            >
              {tab === 'world' ? (
                <div className="shrink-0 w-10 h-7 rounded-md overflow-hidden border border-white/15 shadow-sm relative">
                  <svg
                    viewBox="0 0 24 16"
                    preserveAspectRatio="xMidYMid slice"
                    className="w-full h-full block"
                  >
                    {it.code && FLAGS[it.code]}
                  </svg>
                </div>
              ) : (
                <div className="shrink-0 w-9 h-9 rounded-xl bg-brand-500/10 border border-brand-400/20 grid place-items-center">
                  <TickCircle size={16} variant="Bold" className="text-brand-300" />
                </div>
              )}

              <div className="min-w-0 flex-1">
                <div className="text-[13.5px] sm:text-sm font-semibold text-white truncate">
                  {it.name}
                </div>
                {it.sub && (
                  <div className="text-[11px] text-slate-400 truncate mt-0.5">
                    {it.sub}
                  </div>
                )}
              </div>

              <ArrowRight
                size={14}
                className="text-slate-500 opacity-0 group-hover:opacity-100 group-hover:text-brand-300 transition-all -translate-x-1 group-hover:translate-x-0"
              />
            </motion.div>
          ))}
        </motion.div>

        {/* Footer note */}
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          className="mt-10 flex items-center justify-center gap-2 text-xs sm:text-sm text-slate-400"
        >
          <span className="inline-block w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
          {t('coverage.note')}
        </motion.div>
      </div>
    </section>
  );
}
