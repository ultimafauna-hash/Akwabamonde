import React, { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { 
  ChevronLeft, 
  ChevronRight, 
  ArrowRight, 
  ArrowLeft,
  Clock, 
  MapPin, 
  User, 
  Calendar,
  Play,
  Image as ImageIcon,
  Heart,
  Eye,
  Share2
} from 'lucide-react';
import { CulturePost } from '../types';
import { cn, safeFormatDate, optimizeImage, getYoutubeId } from '../lib/utils';
import ReactMarkdown from 'react-markdown';

const categoryConfig: Record<string, { icon: string, bg: string, text: string }> = {
  patrimoine: { icon: '🏛️', bg: 'bg-amber-100', text: 'text-amber-700' },
  traditions: { icon: '🎭', bg: 'bg-purple-100', text: 'text-purple-700' },
  personnages: { icon: '👑', bg: 'bg-indigo-100', text: 'text-indigo-700' },
  civilisations: { icon: '⚱️', bg: 'bg-orange-100', text: 'text-orange-700' },
  art: { icon: '🎨', bg: 'bg-rose-100', text: 'text-rose-700' },
  musique: { icon: '🎵', bg: 'bg-emerald-100', text: 'text-emerald-700' },
  gastronomie: { icon: '🍲', bg: 'bg-red-100', text: 'text-red-700' },
  langues: { icon: '💬', bg: 'bg-cyan-100', text: 'text-cyan-700' }
};

export const CultureCard = ({ post, onClick }: { post: CulturePost, onClick: (p: CulturePost) => void }) => {
  const config = categoryConfig[post.category] || { icon: '📜', bg: 'bg-slate-100', text: 'text-slate-700' };
  
  return (
    <div 
      onClick={() => onClick(post)}
      className="bg-white rounded-[2.5rem] overflow-hidden shadow-lg border border-slate-100 cursor-pointer group hover:shadow-2xl transition-all duration-500 h-full flex flex-col African-card-shadow"
    >
      <div className="relative aspect-[16/10] overflow-hidden bg-slate-50">
        {post.image && (
          <img 
            src={optimizeImage(post.image, 800)} 
            alt={post.title} 
            className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110" 
            referrerPolicy="no-referrer"
          />
        )}
        
        {/* Badges on image */}
        <div className="absolute top-4 left-4 flex flex-col gap-2">
          {post.video && (
            <div className="bg-red-600 text-white px-3 py-1 rounded-full text-[9px] font-black uppercase tracking-widest flex items-center gap-1.5 shadow-lg">
              <Play size={10} fill="currentColor" />
              VIDÉO
            </div>
          )}
          {post.gallery && post.gallery.length > 0 && (
            <div className="bg-black/60 text-white px-3 py-1 rounded-full text-[9px] font-black uppercase tracking-widest flex items-center gap-1.5 backdrop-blur-md">
              <ImageIcon size={10} />
              +{post.gallery.length} PHOTOS
            </div>
          )}
        </div>

        {post.video && (
           <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
              <div className="w-16 h-16 bg-white/20 backdrop-blur-md rounded-full flex items-center justify-center border border-white/30 scale-90 group-hover:scale-100 transition-transform duration-500">
                 <Play size={24} fill="white" className="text-white ml-1" />
              </div>
           </div>
        )}

        <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
      </div>

      <div className="p-8 flex flex-col flex-1 space-y-5">
        <div className="flex items-center gap-3">
          <span className={cn("px-4 py-1.5 rounded-full text-[10px] font-black uppercase tracking-widest flex items-center gap-2", config.bg, config.text)}>
            <span>{config.icon}</span>
            {post.category}
          </span>
          <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">
             {post.region}
          </span>
        </div>
        
        <h3 className="font-black text-2xl text-slate-900 leading-tight group-hover:text-primary transition-colors line-clamp-2">
          {post.title}
        </h3>

        <p className="text-sm text-slate-500 line-clamp-2 leading-relaxed">
          {post.excerpt}
        </p>

        <div className="pt-6 border-t border-slate-100 flex items-center justify-between mt-auto">
          <div className="flex items-center gap-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">
            <div className="flex items-center gap-1.5">
              <Clock size={14} className="text-primary" />
              {post.readingtime}
            </div>
            <div className="flex items-center gap-1.5">
              <User size={14} className="text-primary" />
              {post.period}
            </div>
          </div>
          
          <div className="w-10 h-10 rounded-full bg-slate-50 flex items-center justify-center text-slate-900 group-hover:bg-primary group-hover:text-white transition-all shadow-sm">
             <ArrowRight size={18} />
          </div>
        </div>
      </div>
    </div>
  );
};

export const CultureSection = ({ posts, onPostClick, onSeeAll }: { posts: CulturePost[], onPostClick: (p: CulturePost) => void, onSeeAll: () => void }) => {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [itemsPerPage, setItemsPerPage] = useState(3);
  const [isPaused, setIsPaused] = useState(false);

  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth < 768) setItemsPerPage(1);
      else if (window.innerWidth < 1024) setItemsPerPage(2);
      else setItemsPerPage(3);
    };
    handleResize();
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const totalItems = posts.length;
  const next = () => setCurrentIndex((prev) => (totalItems > 0 ? (prev + 1) % totalItems : 0));
  const prev = () => setCurrentIndex((prev) => (totalItems > 0 ? (prev - 1 + totalItems) % totalItems : 0));

  useEffect(() => {
    if (isPaused || totalItems === 0) return;
    const timer = setInterval(next, 6000);
    return () => clearInterval(timer);
  }, [totalItems, isPaused, itemsPerPage]);

  return (
    <section 
      className="py-24 bg-[#FAF9F6]African-pattern overflow-hidden relative"
      onMouseEnter={() => setIsPaused(true)}
      onMouseLeave={() => setIsPaused(false)}
    >
      <div className="max-w-7xl mx-auto px-4 mb-20 relative z-10">
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-8">
          <div className="space-y-6">
             <div className="flex items-center gap-3">
                <div className="w-12 h-1.5 bg-primary rounded-full shadow-lg shadow-primary/20" />
                <span className="text-secondary font-black text-[10px] uppercase tracking-[0.4em]">Trésors du Continent</span>
             </div>
             <h2 className="text-6xl md:text-8xl font-black italic tracking-tighter uppercase leading-[0.85] African-text-shadow">
               Histoire & <br/> <span className="text-primary">Culture</span>
             </h2>
          </div>
          <div className="flex items-center gap-6">
             <div className="flex gap-3">
                <button 
                  onClick={prev} 
                  className="w-16 h-16 rounded-full bg-white text-slate-400 hover:bg-primary hover:text-white transition-all flex items-center justify-center border border-slate-200 shadow-xl active:scale-90"
                >
                  <ChevronLeft size={28} />
                </button>
                <button 
                  onClick={next} 
                  className="w-16 h-16 rounded-full bg-white text-slate-400 hover:bg-primary hover:text-white transition-all flex items-center justify-center border border-slate-200 shadow-xl active:scale-90"
                >
                  <ChevronRight size={28} />
                </button>
             </div>
             <button 
               onClick={onSeeAll}
               className="h-16 bg-slate-900 hover:bg-primary text-white px-12 rounded-full font-black text-[11px] uppercase tracking-widest transition-all shadow-2xl active:scale-95 hidden sm:flex items-center gap-3"
             >
               Voir toute la collection
               <ArrowRight size={16} />
             </button>
          </div>
        </div>
      </div>

      <div className="relative px-4 z-10">
        <div className="max-w-7xl mx-auto overflow-visible relative">
          <motion.div 
            animate={{ x: `-${currentIndex * (100 / itemsPerPage)}%` }}
            transition={{ type: "spring", damping: 30, stiffness: 60 }}
            className="flex"
          >
            {posts.map((post) => (
              <div 
                key={post.id}
                className={cn(
                  "flex-shrink-0 px-4 transition-all duration-700",
                  itemsPerPage === 3 ? "w-1/3" : itemsPerPage === 2 ? "w-1/2" : "w-full"
                )}
              >
                <CultureCard post={post} onClick={onPostClick} />
              </div>
            ))}
          </motion.div>
        </div>
      </div>
      
      <div className="flex justify-center gap-4 mt-20 max-w-7xl mx-auto px-4 z-10">
         {posts.map((_, i) => (
           <button
             key={i}
             onClick={() => setCurrentIndex(i)}
             className={cn(
               "h-2.5 rounded-full transition-all duration-700 shadow-sm",
               currentIndex === i ? "w-16 bg-primary" : "w-2.5 bg-slate-200 hover:bg-slate-300"
             )}
           />
         ))}
      </div>
    </section>
  );
};

export const CultureDetailView = ({ post, onBack }: { post: CulturePost, onBack: () => void }) => {
  if (!post) return null;
  return (
    <motion.div 
      initial={{ opacity: 0, scale: 0.98 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.98 }}
      transition={{ duration: 0.6 }}
      className="max-w-5xl mx-auto"
    >
      <div className="mb-8 flex items-center justify-between">
        <button 
          onClick={onBack} 
          className="group flex items-center gap-3 bg-white border border-slate-100 px-6 py-3 rounded-full text-xs font-black uppercase tracking-widest shadow-sm hover:shadow-lg transition-all active:scale-95"
        >
          <ArrowLeft size={16} className="group-hover:-translate-x-1 transition-transform" /> 
          Retour
        </button>
        <div className="flex gap-2">
            <button className="w-10 h-10 rounded-full bg-white border border-slate-100 flex items-center justify-center text-slate-400 hover:text-red-500 hover:bg-red-50 transition-all">
                <Heart size={18} />
            </button>
            <button className="w-10 h-10 rounded-full bg-white border border-slate-100 flex items-center justify-center text-slate-400 hover:text-primary hover:bg-primary/5 transition-all">
                <Share2 size={18} />
            </button>
        </div>
      </div>
      
      <div className="bg-white rounded-[3rem] overflow-hidden shadow-2xl border border-slate-100 अफ्रीकी-detail-view pb-16">
        <header className="relative w-full aspect-square md:aspect-[21/9] African-header-pattern">
          {post.image && (
            <img src={post.image} className="w-full h-full object-cover" alt={post.title} referrerPolicy="no-referrer" />
          )}
          <div className="absolute inset-0 bg-gradient-to-t from-slate-900/80 via-slate-900/40 to-transparent" />
          <div className="absolute bottom-6 md:bottom-12 left-6 md:left-12 right-6 md:right-12 text-white">
            <div className="flex flex-wrap items-center gap-3 md:gap-4 mb-4 md:mb-6">
                <span className={cn("px-4 md:px-5 py-1.5 md:py-2 rounded-full text-[10px] md:text-xs font-black uppercase tracking-[0.2em] shadow-lg", categoryConfig[post.category]?.bg || 'bg-slate-100', categoryConfig[post.category]?.text || 'text-slate-900')}>
                    {post.category || 'Culture'}
                </span>
                <div className="flex items-center gap-2 text-white/80 font-bold uppercase tracking-widest text-[9px] md:text-[10px]">
                    <MapPin size={14} />
                    {post.region || 'Afrique'}
                </div>
            </div>
            <h1 className="text-3xl md:text-4xl lg:text-6xl font-black African-title tracking-tight max-w-4xl text-white drop-shadow-2xl leading-tight">
              {post.title || 'Sans titre'}
            </h1>
          </div>
        </header>

        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 md:gap-12 p-6 md:p-12">
            <div className="lg:col-span-8 space-y-8 md:space-y-12">
                <div className="flex flex-wrap items-center gap-6 md:gap-8 py-6 md:py-8 border-y border-slate-100">
                    <div className="flex flex-col">
                        <span className="text-[9px] md:text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">Rédigé par</span>
                        <div className="flex items-center gap-3">
                            <div className="w-8 h-8 md:w-10 md:h-10 bg-primary/10 rounded-full flex items-center justify-center text-primary font-black text-xs md:text-base">
                                {(post.author || 'A')[0]}
                            </div>
                            <span className="font-black text-xs md:text-sm">{post.author || 'Rédaction'}</span>
                        </div>
                    </div>
                    <div className="flex flex-col">
                        <span className="text-[9px] md:text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">Période</span>
                        <div className="flex items-center gap-2">
                             <Calendar size={16} className="text-primary md:w-[18px] md:h-[18px]" />
                             <span className="font-black text-xs md:text-sm">{post.period || 'Non précisé'}</span>
                        </div>
                    </div>
                    <div className="flex flex-col">
                        <span className="text-[9px] md:text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">Lecture</span>
                        <div className="flex items-center gap-2">
                             <Clock size={16} className="text-primary md:w-[18px] md:h-[18px]" />
                             <span className="font-black text-xs md:text-sm">{post.readingtime}</span>
                        </div>
                    </div>
                </div>

                <div className="prose prose-slate African-content max-w-none">
                    <ReactMarkdown>{post.content || ''}</ReactMarkdown>
                </div>

                {post.video && getYoutubeId(post.video) && (
                    <div className="w-full rounded-[2.5rem] overflow-hidden shadow-2xl bg-black/5 aspect-video border-[10px] border-white African-video-frame">
                        <iframe 
                            src={`https://www.youtube.com/embed/${getYoutubeId(post.video)}`}
                            title={post.title}
                            className="w-full h-full"
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                            allowFullScreen
                        />
                    </div>
                )}

                {post.gallery && post.gallery.length > 0 && (
                    <div className="space-y-6">
                        <h3 className="text-2xl font-black Kenyan-title">Galerie d'images</h3>
                        <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                            {post.gallery.map((img, i) => (
                                <div key={i} className="aspect-square rounded-[2rem] overflow-hidden African-gallery-item border-4 border-white shadow-md hover:scale-105 transition-transform duration-500">
                                    <img src={img} className="w-full h-full object-cover" alt={`${post.title} - ${i}`} referrerPolicy="no-referrer" />
                                </div>
                            ))}
                        </div>
                    </div>
                )}
            </div>

            <aside className="lg:col-span-4 space-y-12">
                <div className="p-8 bg-[#FAF9F6] rounded-[2.5rem] border border-slate-100 shadow-sm space-y-8 sticky top-8">
                    <h3 className="text-xl font-black Kenyan-title border-b border-primary/20 pb-4">Statistiques</h3>
                    <div className="space-y-6">
                        <div className="flex items-center justify-between">
                            <div className="flex items-center gap-3 text-slate-500 font-bold">
                                <Eye size={20} className="text-primary" />
                                <span>Vues</span>
                            </div>
                            <span className="font-black text-lg">{post.views}</span>
                        </div>
                        <div className="flex items-center justify-between">
                            <div className="flex items-center gap-3 text-slate-500 font-bold">
                                <Heart size={20} className="text-primary" />
                                <span>Mentions j'aime</span>
                            </div>
                            <span className="font-black text-lg">{post.likes}</span>
                        </div>
                        <div className="flex items-center justify-between">
                            <div className="flex items-center gap-3 text-slate-500 font-bold">
                                <Calendar size={20} className="text-primary" />
                                <span>Publié le</span>
                            </div>
                            <span className="font-black text-sm">{safeFormatDate(post.createdat, 'dd MMM yyyy')}</span>
                        </div>
                    </div>

                    <div className="pt-8 border-t border-slate-100 space-y-4">
                        <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest text-center">Inspiré par cette histoire ?</p>
                        <button className="w-full bg-primary text-white African-btn-shadow py-4 rounded-full font-black text-xs uppercase tracking-widest hover:bg-slate-900 transition-all flex items-center justify-center gap-2 active:scale-95">
                            <Share2 size={16} />
                            Partager avec le monde
                        </button>
                    </div>
                </div>
            </aside>
        </div>
      </div>
    </motion.div>
  );
};
