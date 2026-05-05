import { motion } from 'framer-motion';
import { Truck, Box1, ShoppingCart, Mobile, Monitor } from 'iconsax-react';
import { useT } from '../i18n';

export function AppsShowcase() {
  const t = useT();
  const APPS = [
    {
      key: 'sender',
      name: t('apps.sender.name'),
      desc: t('apps.sender.desc'),
      color: 'from-blue-500 to-indigo-700',
      icon: <Box1 size={28} variant="Bold" />,
      badges: ['iOS', 'Android', 'Web'],
      image:
        'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=900&q=70',
    },
    {
      key: 'driver',
      name: t('apps.driver.name'),
      desc: t('apps.driver.desc'),
      color: 'from-teal-500 to-emerald-700',
      icon: <Truck size={28} variant="Bold" />,
      badges: ['iOS', 'Android'],
      image:
        'https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?auto=format&fit=crop&w=900&q=70',
    },
    {
      key: 'customer',
      name: t('apps.customer.name'),
      desc: t('apps.customer.desc'),
      color: 'from-emerald-500 to-green-700',
      icon: <ShoppingCart size={28} variant="Bold" />,
      badges: ['iOS', 'Android'],
      image:
        'https://images.unsplash.com/photo-1581094794329-c8112a89af12?auto=format&fit=crop&w=900&q=70',
    },
  ];

  return (
    <section id="apps" className="py-20 sm:py-24 px-5 sm:px-6 relative">
      <div className="absolute inset-0 bg-gradient-to-b from-transparent via-brand-500/5 to-transparent pointer-events-none" />
      <div className="max-w-7xl mx-auto relative">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="text-center mb-12 sm:mb-16"
        >
          <span className="inline-block px-3 py-1 rounded-full bg-brand-500/10 text-brand-400 text-[11px] sm:text-xs font-semibold uppercase tracking-wider mb-3">
            {t('apps.badge')}
          </span>
          <h2 className="text-3xl sm:text-4xl md:text-5xl font-extrabold mb-4 leading-tight">
            {t('apps.title.a')}{' '}
            <span className="bg-gradient-to-r from-brand-400 to-brand-600 bg-clip-text text-transparent">
              {t('apps.title.b')}
            </span>{' '}
            {t('apps.title.c')}
          </h2>
          <p className="text-slate-400 text-sm sm:text-base max-w-2xl mx-auto">
            {t('apps.subtitle')}
          </p>
        </motion.div>

        <div className="grid md:grid-cols-3 gap-5 sm:gap-6">
          {APPS.map((app, i) => (
            <motion.div
              key={app.key}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.1 }}
              whileHover={{ y: -8 }}
              className="group relative bg-slate-900/60 border border-white/10 rounded-3xl overflow-hidden backdrop-blur"
            >
              <div className="relative h-44 overflow-hidden">
                <img
                  src={app.image}
                  alt={app.name}
                  className="w-full h-full object-cover opacity-50 group-hover:opacity-70 group-hover:scale-110 transition-all duration-700"
                />
                <div
                  className={`absolute inset-0 bg-gradient-to-t ${app.color} opacity-60 mix-blend-multiply`}
                />
                <div
                  className={`absolute top-4 left-4 w-12 h-12 rounded-xl bg-gradient-to-br ${app.color} grid place-items-center text-white shadow-lg`}
                >
                  {app.icon}
                </div>
              </div>
              <div className="p-5 sm:p-6">
                <h3 className="text-xl font-bold mb-2">{app.name}</h3>
                <p className="text-slate-400 text-sm mb-4 leading-relaxed">{app.desc}</p>
                <div className="flex items-center gap-2 flex-wrap">
                  {app.badges.map((b) => (
                    <span
                      key={b}
                      className="inline-flex items-center gap-1 text-[11px] font-medium text-slate-300 bg-white/5 border border-white/10 px-2 py-1 rounded-md"
                    >
                      {b === 'Web' ? <Monitor size={11} /> : <Mobile size={11} />} {b}
                    </span>
                  ))}
                </div>
              </div>
              <div
                className={`absolute -inset-px bg-gradient-to-r ${app.color} opacity-0 group-hover:opacity-20 transition-opacity duration-500 rounded-3xl pointer-events-none`}
              />
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
