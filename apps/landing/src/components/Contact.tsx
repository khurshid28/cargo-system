import { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Sms,
  Call,
  Location,
  User,
  MessageText1,
  Send2,
  TickCircle,
  Clock,
  Briefcase,
  ArrowDown2,
  Box,
  Truck,
  Shop,
  Buildings2,
  More,
} from 'iconsax-react';
import { useT } from '../i18n';

type RoleVal = 'sender' | 'driver' | 'merchant' | 'partner' | 'other';

// Format raw digits (without country code) to "## ### ## ##"
function formatPhone(digits: string): string {
  // strip everything but digits, drop leading 998 if present
  let d = digits.replace(/\D/g, '');
  if (d.startsWith('998')) d = d.slice(3);
  d = d.slice(0, 9); // max 9 digits after +998
  let out = '+998';
  if (d.length > 0) out += ' ' + d.slice(0, 2);
  if (d.length > 2) out += ' ' + d.slice(2, 5);
  if (d.length > 5) out += ' ' + d.slice(5, 7);
  if (d.length > 7) out += ' ' + d.slice(7, 9);
  return out;
}

export function Contact() {
  const t = useT();

  const ROLES: { value: RoleVal; labelKey: string; icon: JSX.Element; tone: string }[] = [
    { value: 'sender',   labelKey: 'role.sender',   icon: <Box size={18} variant="Bold" />,        tone: 'from-blue-500 to-indigo-700' },
    { value: 'driver',   labelKey: 'role.driver',   icon: <Truck size={18} variant="Bold" />,      tone: 'from-teal-500 to-emerald-700' },
    { value: 'merchant', labelKey: 'role.merchant', icon: <Shop size={18} variant="Bold" />,       tone: 'from-emerald-500 to-green-700' },
    { value: 'partner',  labelKey: 'role.partner',  icon: <Buildings2 size={18} variant="Bold" />, tone: 'from-amber-500 to-orange-700' },
    { value: 'other',    labelKey: 'role.other',    icon: <More size={18} variant="Bold" />,       tone: 'from-slate-500 to-slate-700' },
  ];

  const [form, setForm] = useState({
    name: '',
    phone: '+998',
    email: '',
    role: 'sender' as RoleVal,
    message: '',
  });
  const [sending, setSending] = useState(false);
  const [done, setDone] = useState(false);

  function set<K extends keyof typeof form>(k: K, v: (typeof form)[K]) {
    setForm({ ...form, [k]: v });
  }

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    const digits = form.phone.replace(/\D/g, '');
    if (!form.name || digits.length < 12) return; // 998 + 9 digits
    setSending(true);
    await new Promise((r) => setTimeout(r, 900));
    setSending(false);
    setDone(true);
    setForm({ name: '', phone: '+998', email: '', role: 'sender', message: '' });
    setTimeout(() => setDone(false), 4500);
  }

  return (
    <section id="contact" className="py-16 sm:py-24 px-4 sm:px-6 relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-b from-transparent via-brand-500/5 to-transparent pointer-events-none" />
      <div className="absolute top-1/2 left-1/4 w-56 sm:w-96 h-56 sm:h-96 bg-brand-500/10 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute bottom-0 right-1/4 w-56 sm:w-96 h-56 sm:h-96 bg-emerald-500/10 rounded-full blur-3xl pointer-events-none" />

      <div className="max-w-7xl mx-auto relative">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="text-center mb-12 sm:mb-14"
        >
          <span className="inline-block px-3 py-1 rounded-full bg-brand-500/10 text-brand-400 text-[11px] sm:text-xs font-semibold uppercase tracking-wider mb-3">
            {t('contact.badge')}
          </span>
          <h2 className="text-3xl sm:text-4xl md:text-5xl font-extrabold mb-4 leading-tight">
            {t('contact.title.a')}{' '}
            <span className="bg-gradient-to-r from-brand-400 to-brand-600 bg-clip-text text-transparent">
              {t('contact.title.b')}
            </span>
          </h2>
          <p className="text-slate-400 text-sm sm:text-base max-w-xl mx-auto">
            {t('contact.subtitle')}
          </p>
        </motion.div>

        <div className="grid lg:grid-cols-5 gap-5 sm:gap-8">
          <motion.div
            initial={{ opacity: 0, x: -30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            className="lg:col-span-2 space-y-3 sm:space-y-4 min-w-0"
          >
            <InfoCard icon={<Call size={22} variant="Bold" />} title={t('contact.phone')} value="+998 95 064 28 27" href="tel:+998950642827" tone="from-blue-500 to-indigo-700" />
            <InfoCard icon={<Sms size={22} variant="Bold" />} title={t('contact.email')} value="hello@cargo.uz" href="mailto:hello@cargo.uz" tone="from-emerald-500 to-teal-700" />
            <InfoCard icon={<Location size={22} variant="Bold" />} title={t('contact.address')} value={t('contact.addressVal')} tone="from-rose-500 to-pink-700" />
            <InfoCard icon={<Clock size={22} variant="Bold" />} title={t('contact.hours')} value={t('contact.hoursVal')} tone="from-amber-500 to-orange-700" />
            <div className="bg-slate-900/60 border border-white/10 rounded-2xl p-4 sm:p-5 mt-4">
              <div className="flex items-center gap-2 mb-2 text-sm text-slate-400">
                <Briefcase size={16} className="text-brand-400" /> {t('contact.partnership')}
              </div>
              <p className="text-sm text-slate-300">{t('contact.partnershipText')}</p>
            </div>
          </motion.div>

          <motion.form
            onSubmit={submit}
            initial={{ opacity: 0, x: 30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            className="lg:col-span-3 min-w-0 bg-gradient-to-br from-slate-900/80 to-slate-900/40 border border-white/10 rounded-3xl p-4 sm:p-7 backdrop-blur"
          >
            <div className="grid sm:grid-cols-2 gap-3 sm:gap-4">
              <Field label={t('contact.f.name')} icon={<User size={16} />}>
                <Input required value={form.name} onChange={(e) => set('name', e.target.value)} placeholder={t('contact.f.namePh')} maxLength={60} />
              </Field>
              <Field label={t('contact.f.phone')} icon={<Call size={16} />}>
                <Input
                  required
                  type="tel"
                  inputMode="numeric"
                  value={form.phone}
                  onChange={(e) => set('phone', formatPhone(e.target.value))}
                  onFocus={(e) => {
                    if (!e.target.value || e.target.value === '+998') set('phone', '+998 ');
                  }}
                  placeholder="+998 90 123 45 67"
                  maxLength={17}
                />
              </Field>
              <Field label={t('contact.f.email')} icon={<Sms size={16} />}>
                <Input type="email" value={form.email} onChange={(e) => set('email', e.target.value)} placeholder="email@example.com" maxLength={80} />
              </Field>
              <Field label={t('contact.f.role')} icon={<Briefcase size={16} />}>
                <RoleDropdown value={form.role} onChange={(v) => set('role', v)} options={ROLES.map((r) => ({ ...r, label: t(r.labelKey) }))} />
              </Field>
            </div>
            <div className="mt-4">
              <Field label={t('contact.f.message')} icon={<MessageText1 size={16} />}>
                <textarea
                  rows={4}
                  value={form.message}
                  onChange={(e) => set('message', e.target.value)}
                  placeholder={t('contact.f.messagePh')}
                  maxLength={500}
                  className="w-full min-w-0 bg-white/[0.04] border border-white/10 text-slate-100 px-3 sm:px-3.5 py-2.5 rounded-xl outline-none transition focus:border-brand-500/60 focus:bg-white/[0.06] placeholder:text-slate-500 resize-none text-sm sm:text-base"
                />
              </Field>
            </div>

            <motion.button
              whileHover={{ scale: 1.01 }}
              whileTap={{ scale: 0.99 }}
              type="submit"
              disabled={sending || done}
              className="mt-5 w-full inline-flex items-center justify-center gap-2 py-3.5 rounded-xl font-semibold bg-gradient-to-r from-brand-500 to-brand-700 text-white shadow-lg shadow-brand-500/20 hover:shadow-brand-500/40 transition-shadow disabled:opacity-60"
            >
              {done ? (
                <><TickCircle size={20} variant="Bold" /> {t('contact.done')}</>
              ) : sending ? (
                <>
                  <motion.span animate={{ rotate: 360 }} transition={{ repeat: Infinity, duration: 0.9, ease: 'linear' }} className="inline-block w-4 h-4 border-2 border-white/40 border-t-white rounded-full" />
                  {t('contact.sending')}
                </>
              ) : (
                <><Send2 size={20} variant="Bold" /> {t('contact.submit')}</>
              )}
            </motion.button>

            <AnimatePresence>
              {done && (
                <motion.div initial={{ opacity: 0, y: -8 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }} className="mt-3 text-emerald-400 text-sm text-center">
                  {t('contact.doneSub')}
                </motion.div>
              )}
            </AnimatePresence>

            <p className="text-xs text-slate-500 text-center mt-4">{t('contact.terms')}</p>
          </motion.form>
        </div>
      </div>
    </section>
  );
}

function Field({ label, icon, children }: { label: string; icon: React.ReactNode; children: React.ReactNode }) {
  return (
    <label className="block">
      <span className="flex items-center gap-1.5 text-[11px] sm:text-xs font-semibold text-slate-400 uppercase tracking-wider mb-1.5">
        <span className="text-brand-400">{icon}</span> {label}
      </span>
      {children}
    </label>
  );
}

function Input(props: React.InputHTMLAttributes<HTMLInputElement>) {
  return (
    <input
      {...props}
      className="w-full min-w-0 bg-white/[0.04] border border-white/10 text-slate-100 px-3 sm:px-3.5 py-2.5 rounded-xl outline-none transition focus:border-brand-500/60 focus:bg-white/[0.06] placeholder:text-slate-500 text-sm sm:text-base"
    />
  );
}

function RoleDropdown({
  value,
  onChange,
  options,
}: {
  value: RoleVal;
  onChange: (v: RoleVal) => void;
  options: { value: RoleVal; label: string; icon: JSX.Element; tone: string }[];
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const current = options.find((o) => o.value === value)!;

  useEffect(() => {
    function onClick(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    }
    document.addEventListener('mousedown', onClick);
    return () => document.removeEventListener('mousedown', onClick);
  }, []);

  return (
    <div ref={ref} className="relative">
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        className="w-full min-w-0 flex items-center gap-2 sm:gap-2.5 bg-white/[0.04] border border-white/10 hover:bg-white/[0.07] text-slate-100 px-3 sm:px-3.5 py-2.5 rounded-xl outline-none transition focus:border-brand-500/60"
      >
        <span className={`w-7 h-7 rounded-lg bg-gradient-to-br ${current.tone} grid place-items-center text-white shrink-0`}>
          {current.icon}
        </span>
        <span className="font-medium text-sm flex-1 text-left truncate">{current.label}</span>
        <ArrowDown2 size={16} className={`text-slate-400 transition shrink-0 ${open ? 'rotate-180' : ''}`} />
      </button>
      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0, y: -6, scale: 0.98 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -6, scale: 0.98 }}
            transition={{ duration: 0.15 }}
            className="absolute left-0 right-0 top-full mt-2 bg-slate-900/95 backdrop-blur-xl border border-white/10 rounded-xl shadow-2xl overflow-hidden z-50"
          >
            {options.map((o, i) => (
              <motion.button
                key={o.value}
                type="button"
                initial={{ opacity: 0, x: -8 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: i * 0.03 }}
                onClick={() => { onChange(o.value); setOpen(false); }}
                className={`w-full flex items-center gap-2.5 px-3.5 py-2.5 text-sm transition ${
                  o.value === value ? 'bg-brand-500/15 text-brand-200' : 'text-slate-200 hover:bg-white/5'
                }`}
              >
                <span className={`w-7 h-7 rounded-lg bg-gradient-to-br ${o.tone} grid place-items-center text-white shrink-0`}>
                  {o.icon}
                </span>
                <span className="font-medium flex-1 text-left">{o.label}</span>
                {o.value === value && <TickCircle size={16} variant="Bold" className="text-brand-400" />}
              </motion.button>
            ))}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

function InfoCard({
  icon, title, value, href, tone,
}: {
  icon: React.ReactNode; title: string; value: string; href?: string; tone: string;
}) {
  const inner = (
    <motion.div whileHover={{ y: -4 }} className="bg-slate-900/60 border border-white/10 rounded-2xl p-3.5 sm:p-4 flex items-center gap-3 sm:gap-3.5 backdrop-blur transition">
      <div className={`w-11 h-11 sm:w-12 sm:h-12 rounded-xl bg-gradient-to-br ${tone} grid place-items-center text-white shadow-lg shrink-0`}>
        {icon}
      </div>
      <div className="min-w-0 flex-1">
        <div className="text-[11px] sm:text-xs text-slate-400">{title}</div>
        <div className="font-semibold truncate text-sm sm:text-base">{value}</div>
      </div>
    </motion.div>
  );
  return href ? <a href={href} className="block">{inner}</a> : inner;
}
