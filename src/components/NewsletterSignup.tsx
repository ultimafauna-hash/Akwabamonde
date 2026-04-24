import React, { useState } from 'react';
import { Mail, CheckCircle, AlertTriangle, Send, Loader2 } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { SupabaseService } from '../lib/supabase';
import { cn } from '../lib/utils';

interface NewsletterSignupProps {
  variant?: 'sidebar' | 'footer';
  className?: string;
}

export const NewsletterSignup: React.FC<NewsletterSignupProps> = ({ 
  variant = 'sidebar',
  className 
}) => {
  const [email, setEmail] = useState('');
  const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle');
  const [message, setMessage] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !email.includes('@')) {
      setStatus('error');
      setMessage('Veuillez entrer une adresse email valide.');
      return;
    }

    setStatus('loading');
    try {
      await SupabaseService.subscribe(email);
      setStatus('success');
      setMessage('Merci ! Vous êtes maintenant abonné à notre newsletter.');
      setEmail('');
    } catch (error: any) {
      console.error('Subscription error:', error);
      setStatus('error');
      setMessage(error.message || 'Une erreur est survenue. Veuillez réessayer.');
    }
  };

  const isSidebar = variant === 'sidebar';

  return (
    <div className={cn(
      "relative overflow-hidden rounded-3xl transition-all duration-300",
      isSidebar 
        ? "bg-white border border-slate-100 p-6 shadow-sm" 
        : "bg-primary/5 p-8 border border-primary/10",
      className
    )}>
      {/* Background Decor */}
      <div className="absolute -top-10 -right-10 w-32 h-32 bg-primary/5 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute -bottom-10 -left-10 w-32 h-32 bg-secondary/5 rounded-full blur-3xl pointer-events-none" />

      <div className="relative z-10">
        <div className="flex items-center gap-3 mb-4">
          <div className={cn(
            "p-2 rounded-xl flex items-center justify-center",
            isSidebar ? "bg-primary/10 text-primary" : "bg-primary text-white"
          )}>
            <Mail className="w-5 h-5" />
          </div>
          <h3 className={cn(
            "font-display font-bold tracking-tight",
            isSidebar ? "text-lg text-slate-900" : "text-xl text-slate-900"
          )}>
            Newsletter
          </h3>
        </div>

        <p className={cn(
          "mb-6 text-sm leading-relaxed",
          isSidebar ? "text-slate-500" : "text-slate-600 max-w-md"
        )}>
          {isSidebar 
            ? "Recevez l'essentiel de l'actualité africaine et mondiale directement dans votre boîte mail."
            : "Rejoignez notre communauté de lecteurs avertis. L'info du monde en un clic, chaque matin."}
        </p>

        <form onSubmit={handleSubmit} className="relative group">
          <div className="relative flex items-center">
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="votre@email.com"
              disabled={status === 'loading' || status === 'success'}
              className={cn(
                "w-full pl-4 pr-12 py-3 rounded-2xl bg-slate-50 border transition-all duration-300 outline-none placeholder:text-slate-400 text-sm",
                status === 'error' 
                  ? "border-red-200 focus:border-red-400 ring-2 ring-red-50" 
                  : "border-slate-200 focus:border-primary/50 focus:ring-4 focus:ring-primary/10"
              )}
            />
            <button
              type="submit"
              disabled={status === 'loading' || status === 'success'}
              className={cn(
                "absolute right-1 w-10 h-10 rounded-xl flex items-center justify-center transition-all duration-300",
                status === 'success' 
                  ? "bg-green-500 text-white" 
                  : status === 'loading'
                    ? "bg-slate-100 text-slate-400"
                    : "bg-primary hover:bg-primary/90 text-white shadow-lg shadow-primary/20"
              )}
            >
              {status === 'loading' ? (
                <Loader2 className="w-4 h-4 animate-spin" />
              ) : status === 'success' ? (
                <CheckCircle className="w-4 h-4" />
              ) : (
                <Send className="w-4 h-4" />
              )}
            </button>
          </div>

          <AnimatePresence mode="wait">
            {message && (
              <motion.div
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className={cn(
                  "mt-3 flex items-start gap-2 text-xs font-medium",
                  status === 'success' ? "text-green-600" : "text-red-500"
                )}
              >
                {status === 'success' ? (
                  <CheckCircle className="w-3.5 h-3.5 mt-0.5 shrink-0" />
                ) : (
                  <AlertTriangle className="w-3.5 h-3.5 mt-0.5 shrink-0" />
                )}
                <span>{message}</span>
              </motion.div>
            )}
          </AnimatePresence>
        </form>

        <p className="mt-4 text-[10px] text-slate-400 font-medium text-center italic">
          Garanti sans spam. Désinscrivez-vous à tout moment.
        </p>
      </div>
    </div>
  );
};
