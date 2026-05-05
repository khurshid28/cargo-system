import { motion } from 'framer-motion';

export function Logo({ className = 'h-8 w-8' }: { className?: string }) {
  return (
    <motion.div
      initial={{ rotate: -10, scale: 0.9 }}
      animate={{ rotate: 0, scale: 1 }}
      transition={{ type: 'spring', stiffness: 200, damping: 12 }}
      className={`${className} grid place-items-center rounded-xl bg-gradient-to-br from-brand-400 to-brand-700 shadow-lg shadow-brand-500/30`}
    >
      <img
        src="https://api.iconify.design/mdi/truck-fast.svg?color=white"
        alt="Cargo logo"
        className="w-2/3 h-2/3"
        loading="eager"
      />
    </motion.div>
  );
}
