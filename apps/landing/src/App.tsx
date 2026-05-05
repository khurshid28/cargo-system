import { Navbar } from './components/Navbar';
import { Hero } from './components/Hero';
import { Partners } from './components/Partners';
import { Features } from './components/Features';
import { AppsShowcase } from './components/AppsShowcase';
import { HowItWorks } from './components/HowItWorks';
import { Stats } from './components/Stats';
import { Coverage } from './components/Coverage';
import { Testimonials } from './components/Testimonials';
import { Pricing } from './components/Pricing';
import { FAQ } from './components/FAQ';
import { Contact } from './components/Contact';
import { CTA } from './components/CTA';
import { Footer } from './components/Footer';
import { Splash } from './components/Splash';

export function App() {
  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 overflow-x-hidden relative">
      <Splash />
      {/* Decorative background blobs */}
      <div className="pointer-events-none fixed inset-0 -z-10 overflow-hidden">
        <div className="absolute -top-32 -left-32 w-[600px] h-[600px] bg-brand-500/10 rounded-full blur-[120px] animate-float" />
        <div className="absolute top-1/3 -right-32 w-[500px] h-[500px] bg-emerald-500/10 rounded-full blur-[120px] animate-float [animation-delay:2s]" />
        <div className="absolute bottom-0 left-1/3 w-[600px] h-[600px] bg-purple-500/10 rounded-full blur-[120px] animate-float [animation-delay:4s]" />
        <div
          className="absolute inset-0 opacity-[0.04]"
          style={{
            backgroundImage:
              'radial-gradient(circle at 1px 1px, white 1px, transparent 0)',
            backgroundSize: '40px 40px',
          }}
        />
      </div>
      <Navbar />
      <main>
        <Hero />
        <Partners />
        <Stats />
        <Features />
        <AppsShowcase />
        <HowItWorks />
        <Coverage />
        <Testimonials />
        <Pricing />
        <FAQ />
        <Contact />
        <CTA />
      </main>
      <Footer />
    </div>
  );
}
