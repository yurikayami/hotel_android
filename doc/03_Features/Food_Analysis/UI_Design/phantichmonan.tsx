import React, { useState, useEffect } from 'react';
import { 
  Camera, 
  Image as ImageIcon, 
  History, 
  ChevronLeft, 
  Sun, 
  Moon, 
  Coffee,
  Settings,
  Zap,
  Flame,     // For Calories
  Dna,       // For Protein
  Wheat,     // For Carbs
  CheckCircle2,
  Share2,
  MoreHorizontal,
  Trash2,
  Calendar,
  Filter,
  X,
  Grid3X3,     // Icon cho chế độ xem lưới
  Maximize2    // Icon phóng to
} from 'lucide-react';

// --- COMPONENTS ---

// 1. Màn hình Camera (Đã cập nhật nút Thư viện)
const CameraScreen = ({ onCapture, meals, selectedMeal, setSelectedMeal, onSwitchHistory, onOpenGallery }) => {
  return (
    <div className="flex flex-col h-full relative bg-[#121212]">
        {/* Top Overlay */}
        <div className="absolute top-0 left-0 right-0 z-20 pt-8 pb-4 px-6 flex items-center justify-between bg-gradient-to-b from-black/80 to-transparent">
          <button className="w-10 h-10 rounded-full bg-black/40 backdrop-blur-md flex items-center justify-center border border-white/10 active:scale-95 transition-transform">
            <ChevronLeft className="w-6 h-6 text-white" />
          </button>
          <span className="text-sm font-medium bg-[#B6F2BA] text-[#0A3812] px-3 py-1 rounded-full shadow-lg">
             AI Camera
          </span>
          <button className="w-10 h-10 rounded-full bg-black/40 backdrop-blur-md flex items-center justify-center border border-white/10 active:scale-95 transition-transform">
            <Settings className="w-5 h-5 text-white" />
          </button>
        </div>

        {/* Viewfinder */}
        <div className="flex-1 relative bg-[#1E1E1E] w-full overflow-hidden">
            <div className="absolute inset-0 flex items-center justify-center">
                <div className="w-full h-full opacity-60 bg-[url('https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80')] bg-cover bg-center"></div>
                <div className="absolute inset-0 bg-gradient-to-b from-transparent via-[#B6F2BA]/10 to-transparent animate-scan top-[-100%]"></div>
                <div className="absolute w-64 h-64 border border-white/30 rounded-[32px] flex flex-col items-center justify-center shadow-[0_0_0_9999px_rgba(0,0,0,0.5)]">
                    <div className="absolute top-0 left-0 w-6 h-6 border-t-4 border-l-4 border-[#B6F2BA] rounded-tl-2xl -mt-[2px] -ml-[2px]"></div>
                    <div className="absolute top-0 right-0 w-6 h-6 border-t-4 border-r-4 border-[#B6F2BA] rounded-tr-2xl -mt-[2px] -mr-[2px]"></div>
                    <div className="absolute bottom-0 left-0 w-6 h-6 border-b-4 border-l-4 border-[#B6F2BA] rounded-bl-2xl -mb-[2px] -ml-[2px]"></div>
                    <div className="absolute bottom-0 right-0 w-6 h-6 border-b-4 border-r-4 border-[#B6F2BA] rounded-br-2xl -mb-[2px] -mr-[2px]"></div>
                </div>
            </div>
            
            <div className="absolute top-24 left-1/2 -translate-x-1/2 w-max">
                <div className="bg-black/60 backdrop-blur-md text-white/90 text-xs px-4 py-2 rounded-full border border-white/10 flex items-center gap-2">
                    <Zap size={12} className="text-yellow-400 fill-yellow-400" />
                    <span>Giữ camera ổn định</span>
                </div>
            </div>
        </div>

        {/* Bottom Controls */}
        <div className="bg-[#121212] pt-4 pb-8 rounded-t-[32px] relative -mt-6 z-10 border-t border-zinc-800">
          <div className="w-12 h-1 bg-zinc-700 rounded-full mx-auto mb-6 opacity-50"></div>
            <div className="flex flex-col gap-6">
              <div className="relative h-14">
                <div className="absolute inset-0 flex items-center justify-center overflow-x-auto gap-4 px-4 scrollbar-hide snap-x">
                    {meals.map((meal) => {
                        const isSelected = selectedMeal === meal.id;
                        return (
                            <button 
                                key={meal.id}
                                onClick={() => setSelectedMeal(meal.id)}
                                className={`
                                    flex items-center gap-2 px-5 py-2 rounded-full transition-all duration-300 whitespace-nowrap snap-center
                                    ${isSelected 
                                        ? 'bg-[#B6F2BA] text-[#0A3812] shadow-[0_0_15px_rgba(182,242,186,0.3)] scale-110 font-bold' 
                                        : 'bg-zinc-800/50 text-zinc-400 hover:bg-zinc-800 border border-zinc-700/50'}
                                `}
                            >
                                <span className="text-sm">{meal.label}</span>
                            </button>
                        )
                    })}
                </div>
              </div>

              <div className="flex items-center justify-between px-10">
                <button 
                    onClick={onOpenGallery}
                    className="flex flex-col items-center gap-1 group"
                >
                    <div className="w-14 h-14 rounded-2xl bg-zinc-800 border border-zinc-700 flex items-center justify-center group-active:scale-95 transition-all text-zinc-300 hover:bg-zinc-700 hover:text-white">
                        <ImageIcon size={24} />
                    </div>
                    <span className="text-[10px] text-zinc-500 font-medium group-hover:text-zinc-300">Thư viện</span>
                </button>

                <button 
                  onClick={onCapture}
                  className="relative group active:scale-90 transition-transform duration-200"
                >
                    <div className="w-20 h-20 rounded-full border-4 border-white/20 group-hover:border-white/40 transition-colors"></div>
                    <div className="absolute top-1.5 left-1.5 w-[68px] h-[68px] rounded-full bg-[#B6F2BA] flex items-center justify-center shadow-[0_0_20px_rgba(182,242,186,0.4)]">
                        <Camera size={32} className="text-[#0A3812]" />
                    </div>
                </button>

                <button 
                    onClick={onSwitchHistory}
                    className="flex flex-col items-center gap-1 group"
                >
                    <div className="w-14 h-14 rounded-2xl bg-zinc-800 border border-zinc-700 flex items-center justify-center group-active:scale-95 transition-all text-zinc-300 hover:bg-zinc-700 hover:text-white">
                        <History size={24} />
                    </div>
                    <span className="text-[10px] text-zinc-500 font-medium group-hover:text-zinc-300">Lịch sử</span>
                </button>
              </div>
            </div>
        </div>
    </div>
  );
};

// 2. Màn hình Thư viện (NEW GALLERY SCREEN)
const GalleryScreen = ({ onBack, onSelectImage }) => {
    // Dữ liệu ảnh mẫu
    const galleryImages = [
        { id: 1, url: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80", label: "Cơm tấm" },
        { id: 2, url: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80", label: "Salad" },
        { id: 3, url: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80", label: "Pizza" },
        { id: 4, url: "https://images.unsplash.com/photo-1482049016688-2d3e1b311543?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80", label: "Bánh mì" },
        { id: 5, url: "https://images.unsplash.com/photo-1484723091739-30a097e8f929?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80", label: "Toast" },
        { id: 6, url: "https://images.unsplash.com/photo-1467003909585-2f8a7270028d?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80", label: "Mì ý" },
        { id: 7, url: "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80", label: "Rau trộn" },
        { id: 8, url: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80", label: "Healthy" },
        { id: 9, url: "https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80", label: "Dimsum" },
    ];

    return (
        <div className="flex flex-col h-full bg-[#121212] animate-fade-in-up">
            {/* Header */}
            <div className="pt-8 pb-4 px-6 flex items-center justify-between bg-[#121212] sticky top-0 z-10 border-b border-zinc-900">
               <div className="flex items-center gap-3">
                  <button onClick={onBack} className="p-2 -ml-2 rounded-full hover:bg-zinc-800 text-zinc-400 hover:text-white transition-colors">
                     <ChevronLeft size={24} />
                  </button>
                  <h1 className="text-xl font-semibold text-white">Thư viện ảnh</h1>
               </div>
               <div className="flex gap-2">
                   <button className="p-2 rounded-full hover:bg-zinc-800 text-zinc-400 hover:text-white transition-colors">
                      <Grid3X3 size={20} />
                   </button>
               </div>
            </div>

            {/* Grid Images */}
            <div className="flex-1 overflow-y-auto p-4 scrollbar-hide">
                <div className="grid grid-cols-3 gap-2">
                    {galleryImages.map((img) => (
                        <button 
                            key={img.id} 
                            onClick={() => onSelectImage(img.url)}
                            className="aspect-square rounded-xl overflow-hidden relative group border border-transparent hover:border-[#B6F2BA] transition-all"
                        >
                            <img src={img.url} alt={img.label} className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110" />
                            {/* Overlay khi hover */}
                            <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                                <span className="bg-[#B6F2BA] text-[#0A3812] text-xs font-bold px-3 py-1 rounded-full">
                                    Chọn
                                </span>
                            </div>
                        </button>
                    ))}
                    {/* Placeholder for 'Add more' */}
                    <button className="aspect-square rounded-xl bg-zinc-900 border border-zinc-800 flex flex-col items-center justify-center text-zinc-500 hover:bg-zinc-800 hover:text-zinc-300 transition-colors">
                        <ImageIcon size={24} className="mb-1 opacity-50" />
                        <span className="text-[10px]">Xem thêm</span>
                    </button>
                </div>
            </div>
            
            {/* Bottom info */}
            <div className="p-4 text-center text-zinc-500 text-xs border-t border-zinc-900 bg-[#121212]">
                Hiển thị ảnh từ Album "Món ăn"
            </div>
        </div>
    );
};

// 3. Màn hình Kết Quả (Giữ nguyên, có thể nhận prop image để hiển thị ảnh được chọn)
const ResultScreen = ({ onBack, imageSrc }) => {
  const displayImage = imageSrc || "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80";

  return (
    <div className="flex flex-col h-full bg-[#121212] overflow-y-auto relative animate-fade-in-up">
      <div className="relative h-[320px] w-full shrink-0">
         <img 
           src={displayImage}
           alt="Food" 
           className="w-full h-full object-cover"
         />
         <div className="absolute inset-0 bg-gradient-to-t from-[#121212] via-[#121212]/40 to-transparent"></div>
         <div className="absolute top-0 left-0 right-0 p-6 pt-8 flex justify-between items-center z-10">
            <button 
              onClick={onBack}
              className="w-10 h-10 rounded-full bg-black/30 backdrop-blur-md flex items-center justify-center text-white hover:bg-black/50 transition-colors"
            >
              <ChevronLeft size={24} />
            </button>
            <div className="flex gap-2">
               <button className="w-10 h-10 rounded-full bg-black/30 backdrop-blur-md flex items-center justify-center text-white hover:bg-black/50 transition-colors">
                  <Share2 size={20} />
               </button>
            </div>
         </div>
      </div>

      <div className="flex-1 -mt-16 relative z-10 bg-[#121212] rounded-t-[32px] px-6 pt-2 pb-8 flex flex-col gap-6">
          <div className="w-12 h-1 bg-zinc-800 rounded-full mx-auto mt-4 mb-2"></div>
          <div>
            <div className="flex items-center gap-3 mb-3">
              <span className="bg-[#B6F2BA] text-[#0A3812] text-xs font-bold px-3 py-1 rounded-full uppercase tracking-wider">
                LUNCH
              </span>
              <span className="text-zinc-500 text-sm">23/11/2025 • 16:50</span>
            </div>
            <h1 className="text-3xl font-semibold text-[#E2E2E2] leading-tight">
              Cơm sườn bì chả, Trứng ốp la
            </h1>
          </div>
          <div className="grid grid-cols-3 gap-3">
             <div className="bg-[#2A201A] rounded-2xl p-4 flex flex-col items-center justify-center gap-2 border border-orange-500/20">
                <Flame size={24} className="text-orange-400 fill-orange-400/20" />
                <div className="text-center">
                   <span className="block text-xl font-bold text-orange-200">823</span>
                   <span className="text-[10px] text-orange-400/70 uppercase tracking-wide">Kcal</span>
                </div>
             </div>
             <div className="bg-[#2A1A1C] rounded-2xl p-4 flex flex-col items-center justify-center gap-2 border border-red-500/20">
                <Dna size={24} className="text-red-400" />
                <div className="text-center">
                   <span className="block text-xl font-bold text-red-200">50.3</span>
                   <span className="text-[10px] text-red-400/70 uppercase tracking-wide">Protein (g)</span>
                </div>
             </div>
             <div className="bg-[#2A271A] rounded-2xl p-4 flex flex-col items-center justify-center gap-2 border border-yellow-500/20">
                <Wheat size={24} className="text-yellow-400" />
                <div className="text-center">
                   <span className="block text-xl font-bold text-yellow-200">5.4</span>
                   <span className="text-[10px] text-yellow-400/70 uppercase tracking-wide">Carbs (g)</span>
                </div>
             </div>
          </div>
          <div className="bg-[#1C241D] rounded-2xl p-5 border border-[#2D4532] relative overflow-hidden group">
              <div className="absolute -right-4 -top-4 w-24 h-24 bg-[#B6F2BA]/5 rounded-full blur-2xl group-hover:bg-[#B6F2BA]/10 transition-colors"></div>
              <div className="flex gap-3">
                 <div className="mt-1">
                    <CheckCircle2 className="text-[#B6F2BA]" size={20} />
                 </div>
                 <div>
                    <h3 className="text-[#B6F2BA] font-semibold text-sm mb-1">Đánh giá bữa ăn</h3>
                    <p className="text-zinc-300 text-sm leading-relaxed">
                       Bữa ăn này phù hợp với phác đồ. Lượng calories (823) chiếm 35% nhu cầu ngày. 
                    </p>
                 </div>
              </div>
          </div>
      </div>
    </div>
  );
};

// 4. Màn hình Lịch Sử (Giữ nguyên)
const HistoryScreen = ({ onBack }) => {
  const [activeTimeFilter, setActiveTimeFilter] = useState('all');
  const [activeMealFilter, setActiveMealFilter] = useState('all');

  const historyItems = [
    {
      id: 1,
      title: "Trứng ốp la, Sườn, Cơm trắng",
      calories: 823,
      date: "23/11/2025 16:50",
      image: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80",
      mealType: "lunch"
    },
    {
      id: 2,
      title: "Cơm tấm sườn bì chả, dưa leo",
      calories: 1321,
      date: "21/11/2025 06:46",
      image: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80",
      mealType: "breakfast"
    },
    {
      id: 3,
      title: "Dưa leo",
      calories: 6,
      date: "20/11/2025 10:30",
      image: "https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80",
      mealType: "snack"
    }
  ];

  return (
    <div className="flex flex-col h-full bg-[#121212] animate-fade-in-up">
        {/* Header */}
        <div className="pt-8 pb-4 px-6 flex items-center justify-between bg-[#121212] sticky top-0 z-10 border-b border-zinc-900">
           <div className="flex items-center gap-3">
              <button onClick={onBack} className="p-2 -ml-2 rounded-full hover:bg-zinc-800 text-zinc-400 hover:text-white transition-colors">
                 <ChevronLeft size={24} />
              </button>
              <h1 className="text-xl font-semibold text-white">Lịch sử ăn uống</h1>
           </div>
           <button className="p-2 rounded-full hover:bg-zinc-800 text-zinc-400 hover:text-white transition-colors">
              <Calendar size={20} />
           </button>
        </div>

        <div className="flex-1 overflow-y-auto px-4 pb-6 scrollbar-hide">
           {/* Filters Section */}
           <div className="py-4 space-y-4">
              {/* Time Filter */}
              <div>
                 <div className="text-zinc-500 text-xs font-medium mb-2 pl-1 uppercase tracking-wider">Thời gian</div>
                 <div className="flex gap-2 overflow-x-auto scrollbar-hide">
                    {['Tất cả', 'Hôm nay', 'Tuần này', 'Tháng này'].map((label, idx) => (
                       <button 
                         key={idx}
                         onClick={() => setActiveTimeFilter(idx === 0 ? 'all' : label)}
                         className={`px-4 py-1.5 rounded-full text-xs font-medium border transition-colors whitespace-nowrap
                           ${(idx === 0 && activeTimeFilter === 'all') || activeTimeFilter === label 
                             ? 'bg-[#B6F2BA] text-[#0A3812] border-[#B6F2BA]' 
                             : 'bg-transparent text-zinc-400 border-zinc-700 hover:border-zinc-500'}`}
                       >
                         {label}
                       </button>
                    ))}
                 </div>
              </div>

              {/* Meal Type Filter */}
              <div>
                 <div className="text-zinc-500 text-xs font-medium mb-2 pl-1 uppercase tracking-wider">Loại bữa ăn</div>
                 <div className="flex gap-2 overflow-x-auto scrollbar-hide">
                    {['Tất cả', 'Sáng', 'Trưa', 'Tối', 'Phụ'].map((label, idx) => (
                       <button 
                         key={idx}
                         onClick={() => setActiveMealFilter(idx === 0 ? 'all' : label)}
                         className={`px-4 py-1.5 rounded-full text-xs font-medium border transition-colors whitespace-nowrap
                           ${(idx === 0 && activeMealFilter === 'all') || activeMealFilter === label 
                             ? 'bg-[#D3E3FD] text-[#041E49] border-[#D3E3FD]' // Different color for distinction
                             : 'bg-transparent text-zinc-400 border-zinc-700 hover:border-zinc-500'}`}
                       >
                         {label}
                       </button>
                    ))}
                 </div>
              </div>
           </div>

           {/* Results Summary */}
           <div className="flex items-center justify-between mb-4 mt-2 px-1">
              <span className="text-zinc-500 text-xs">Tìm thấy 3 kết quả</span>
              <button className="text-[#B6F2BA] text-xs flex items-center gap-1">
                 <Filter size={12} /> Lọc nâng cao
              </button>
           </div>

           {/* List Items */}
           <div className="space-y-3">
              {historyItems.map((item) => (
                 <div key={item.id} className="bg-[#1E1E1E] p-3 rounded-[20px] flex gap-4 group hover:bg-[#252525] transition-colors border border-transparent hover:border-zinc-700">
                    {/* Thumbnail */}
                    <div className="w-24 h-24 shrink-0 rounded-2xl overflow-hidden bg-zinc-800">
                       <img src={item.image} alt={item.title} className="w-full h-full object-cover opacity-80 group-hover:opacity-100 transition-opacity" />
                    </div>

                    {/* Content */}
                    <div className="flex-1 flex flex-col justify-between py-1 min-w-0">
                       <div>
                          <h3 className="text-white font-medium text-base leading-snug truncate pr-2">{item.title}</h3>
                          <p className="text-zinc-500 text-xs mt-1">{item.date}</p>
                       </div>
                       
                       <div className="flex items-end justify-between">
                          <div className="flex items-center gap-1 text-orange-300 bg-orange-400/10 px-2 py-1 rounded-lg">
                             <Flame size={14} className="fill-orange-400/20" />
                             <span className="text-xs font-bold">{item.calories} kcal</span>
                          </div>
                          
                          <button className="w-8 h-8 flex items-center justify-center rounded-full text-zinc-500 hover:text-red-400 hover:bg-red-400/10 transition-colors">
                             <Trash2 size={16} />
                          </button>
                       </div>
                    </div>
                 </div>
              ))}
           </div>
        </div>
    </div>
  );
};

// --- MAIN APP ---

const App = () => {
  const [currentScreen, setCurrentScreen] = useState('camera'); // 'camera' | 'result' | 'history' | 'gallery'
  const [selectedMeal, setSelectedMeal] = useState('lunch');
  const [isProcessing, setIsProcessing] = useState(false);
  const [selectedImageSrc, setSelectedImageSrc] = useState(null); // Lưu ảnh được chọn từ thư viện

  const meals = [
    { id: 'breakfast', label: 'Sáng', icon: Sun },
    { id: 'lunch', label: 'Trưa', icon: Sun }, 
    { id: 'dinner', label: 'Tối', icon: Moon },
    { id: 'snack', label: 'Phụ', icon: Coffee },
  ];

  const handleCapture = () => {
    setIsProcessing(true);
    setSelectedImageSrc(null); // Reset ảnh khi chụp mới
    setTimeout(() => {
      setIsProcessing(false);
      setCurrentScreen('result');
    }, 1500); 
  };
  
  const handleSelectGalleryImage = (imgSrc) => {
      setIsProcessing(true);
      setSelectedImageSrc(imgSrc);
      setTimeout(() => {
          setIsProcessing(false);
          setCurrentScreen('result');
      }, 1000);
  }

  return (
    <div className="min-h-screen bg-black text-white font-sans flex justify-center items-center p-4">
      <div className="w-full max-w-md bg-[#121212] h-[850px] rounded-[32px] overflow-hidden shadow-2xl border border-zinc-800 flex flex-col relative">
        
        {currentScreen === 'camera' && (
          <CameraScreen 
             meals={meals}
             selectedMeal={selectedMeal}
             setSelectedMeal={setSelectedMeal}
             onCapture={handleCapture}
             onSwitchHistory={() => setCurrentScreen('history')}
             onOpenGallery={() => setCurrentScreen('gallery')} 
          />
        )}

        {currentScreen === 'result' && (
           <ResultScreen 
                onBack={() => setCurrentScreen('camera')} 
                imageSrc={selectedImageSrc}
           />
        )}

        {currentScreen === 'history' && (
           <HistoryScreen onBack={() => setCurrentScreen('camera')} />
        )}
        
        {currentScreen === 'gallery' && (
           <GalleryScreen 
                onBack={() => setCurrentScreen('camera')} 
                onSelectImage={handleSelectGalleryImage}
           />
        )}

        {/* Processing Overlay */}
        {isProcessing && (
          <div className="absolute inset-0 z-50 bg-black/80 backdrop-blur-sm flex flex-col items-center justify-center">
             <div className="w-16 h-16 border-4 border-[#B6F2BA]/30 border-t-[#B6F2BA] rounded-full animate-spin mb-4"></div>
             <p className="text-[#B6F2BA] font-medium animate-pulse">
                {selectedImageSrc ? "Đang quét ảnh..." : "Đang phân tích..."}
             </p>
          </div>
        )}

      </div>
      
      <style>{`
        .scrollbar-hide::-webkit-scrollbar { display: none; }
        .scrollbar-hide { -ms-overflow-style: none; scrollbar-width: none; }
        
        @keyframes fade-in-up {
          from { opacity: 0; transform: translateY(20px); }
          to { opacity: 1; transform: translateY(0); }
        }
        .animate-fade-in-up { animation: fade-in-up 0.4s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
        
        @keyframes scan {
            0% { top: -100%; }
            100% { top: 200%; }
        }
        .animate-scan { animation: scan 3s linear infinite; }
      `}</style>
    </div>
  );
};

export default App;