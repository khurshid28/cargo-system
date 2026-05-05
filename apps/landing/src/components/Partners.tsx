import { motion } from 'framer-motion';
import { Buildings2 } from 'iconsax-react';
import { useState } from 'react';
import { useT } from '../i18n';

import artelLogo from '../assets/partners/artel.jpg';
import akfaLogo from '../assets/partners/akfa.png';
import roisonLogo from '../assets/partners/roison.webp';
import uzautoLogo from '../assets/partners/uzauto.png';
import chevroletLogo from '../assets/partners/chevrolet.png';
import imzoLogo from '../assets/partners/imzo.png';
import bekobodLogo from '../assets/partners/bekobod.png';
import olmaliqLogo from '../assets/partners/olmaliq.png';
import korzinkaLogo from '../assets/partners/korzinka.png';
import makroLogo from '../assets/partners/makro.webp';
import havasLogo from '../assets/partners/havas.jpg';
import texnomartLogo from '../assets/partners/texnomart.png';
import clickLogo from '../assets/partners/click.png';
import paymeLogo from '../assets/partners/payme.png';
import humoLogo from '../assets/partners/humo.webp';
import uzcardLogo from '../assets/partners/uzcard.png';
import beelineLogo from '../assets/partners/beeline.png';
import uzumLogo from '../assets/partners/uzum.png';

type Partner = { name: string; sector: string; logo: string; tone: string };

const PARTNERS: Partner[] = [
  { name: 'Artel',          sector: 'Maishiy texnika', logo: artelLogo,     tone: 'from-red-500 to-rose-600' },
  { name: 'Akfa',           sector: 'Qurilish',         logo: akfaLogo,      tone: 'from-amber-500 to-orange-600' },
  { name: 'Roison',         sector: 'Maishiy texnika', logo: roisonLogo,    tone: 'from-cyan-500 to-blue-600' },
  { name: 'UzAuto Motors',  sector: 'Avtomobil',        logo: uzautoLogo,    tone: 'from-red-500 to-rose-600' },
  { name: 'Chevrolet',      sector: 'Avtomobil',        logo: chevroletLogo, tone: 'from-yellow-500 to-amber-600' },
  { name: 'Imzo',           sector: 'Maishiy texnika', logo: imzoLogo,      tone: 'from-purple-500 to-fuchsia-600' },
  { name: 'Bekobod Metallurgiya', sector: 'Metallurgiya',     logo: bekobodLogo,   tone: 'from-stone-500 to-zinc-600' },
  { name: 'Olmaliq KMK',    sector: 'Tog‘-kon',         logo: olmaliqLogo,   tone: 'from-amber-600 to-yellow-700' },
  { name: 'Korzinka',       sector: 'Riteyl',           logo: korzinkaLogo,  tone: 'from-emerald-500 to-green-600' },
  { name: 'Makro',          sector: 'Riteyl',           logo: makroLogo,     tone: 'from-teal-500 to-cyan-600' },
  { name: 'Havas',          sector: 'Riteyl',           logo: havasLogo,     tone: 'from-pink-500 to-rose-600' },
  { name: 'Texnomart',      sector: 'Texnika',          logo: texnomartLogo, tone: 'from-blue-600 to-sky-600' },
  { name: 'Click',          sector: 'Fintech',          logo: clickLogo,     tone: 'from-blue-500 to-cyan-600' },
  { name: 'Payme',          sector: 'Fintech',          logo: paymeLogo,     tone: 'from-violet-500 to-purple-600' },
  { name: 'Humo',           sector: 'Bank',             logo: humoLogo,      tone: 'from-orange-500 to-amber-600' },
  { name: 'Uzcard',         sector: 'Bank',             logo: uzcardLogo,    tone: 'from-blue-600 to-indigo-700' },
  { name: 'Beeline',        sector: 'Telekom',          logo: beelineLogo,   tone: 'from-yellow-400 to-amber-500' },
  { name: 'Uzum',           sector: 'Marketplace',      logo: uzumLogo,      tone: 'from-violet-600 to-purple-700' },
];

export function Partners() {
  const t = useT();
  const row1 = PARTNERS.slice(0, 9);
  const row2 = PARTNERS.slice(9);

  return (
    <section className="py-16 sm:py-20 border-y border-white/5 bg-slate-900/40 relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-5 sm:px-6 mb-10">
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="text-center"
        >
          <span className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-amber-500/10 text-amber-400 text-[11px] sm:text-xs font-semibold uppercase tracking-wider mb-3">
            <Buildings2 size={14} variant="Bold" /> {t('partners.badge')}
          </span>
          <h2 className="text-2xl sm:text-3xl md:text-4xl font-extrabold mb-2 leading-tight">
            {t('partners.title.a')}{' '}
            <span className="bg-gradient-to-r from-amber-400 to-orange-500 bg-clip-text text-transparent">
              {t('partners.title.b')}
            </span>{' '}
            {t('partners.title.c')}
          </h2>
          <p className="text-slate-400 text-sm sm:text-base max-w-2xl mx-auto">
            {t('partners.subtitle')}
          </p>
        </motion.div>
      </div>

      <div
        className="relative w-full"
        style={{
          maskImage:
            'linear-gradient(to right, transparent 0, black 8%, black 92%, transparent 100%)',
          WebkitMaskImage:
            'linear-gradient(to right, transparent 0, black 8%, black 92%, transparent 100%)',
        }}
      >
        <Marquee items={row1} direction="left" speed={36} />
        <div className="mt-3 sm:mt-4">
          <Marquee items={row2} direction="right" speed={32} />
        </div>
      </div>
    </section>
  );
}

function Marquee({
  items,
  direction = 'left',
  speed = 32,
}: {
  items: Partner[];
  direction?: 'left' | 'right';
  speed?: number;
}) {
  const animateX = direction === 'left' ? ['0%', '-50%'] : ['-50%', '0%'];
  return (
    <div className="overflow-hidden">
      <motion.div
        className="flex gap-3 sm:gap-4 whitespace-nowrap w-max"
        animate={{ x: animateX }}
        transition={{ repeat: Infinity, duration: speed, ease: 'linear' }}
      >
        {[...items, ...items, ...items].map((p, i) => (
          <PartnerCard key={i} p={p} />
        ))}
      </motion.div>
    </div>
  );
}

function PartnerCard({ p }: { p: Partner }) {
  const [failed, setFailed] = useState(false);
  return (
    <motion.div
      whileHover={{ y: -4, scale: 1.03 }}
      className="shrink-0 inline-flex items-center gap-3 px-4 sm:px-5 py-2.5 sm:py-3 rounded-2xl border border-white/10 bg-white/[0.04] hover:bg-white/[0.08] hover:border-white/20 transition backdrop-blur"
    >
      <div className="w-12 h-12 sm:w-14 sm:h-14 rounded-xl overflow-hidden shrink-0 grid place-items-center">
        {!failed ? (
          <img
            src={p.logo}
            alt={p.name}
            className="w-full h-full object-contain"
            onError={() => setFailed(true)}
            loading="lazy"
            draggable={false}
          />
        ) : (
          <div
            className={`w-full h-full bg-gradient-to-br ${p.tone} grid place-items-center text-white font-extrabold text-base`}
          >
            {p.name[0]}
          </div>
        )}
      </div>
      <div className="text-left">
        <div className="font-semibold text-sm sm:text-base text-white leading-tight">
          {p.name}
        </div>
        <div className="text-[10px] sm:text-xs text-slate-500 leading-tight">{p.sector}</div>
      </div>
    </motion.div>
  );
}
