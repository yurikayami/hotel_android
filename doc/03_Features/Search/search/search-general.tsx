import React, { useState, useMemo } from 'react';
import { Search, ArrowLeft, MoreVertical, Heart, MessageCircle, Share2, Eye, User, ChevronRight, X, MapPin, SlidersHorizontal, ArrowUpDown } from 'lucide-react';

// === 1. HELPER FUNCTIONS ===
const cleanContent = (htmlString) => {
  if (!htmlString) return "";
  const tempDiv = document.createElement("div");
  tempDiv.innerHTML = htmlString;
  let text = tempDiv.textContent || tempDiv.innerText || "";
  return text.replace(/\s+/g, ' ').trim();
};

const formatTimeAgo = (dateString) => {
  const date = new Date(dateString);
  const now = new Date();
  const diffInSeconds = Math.floor((now - date) / 1000);

  if (diffInSeconds < 60) return "Vừa xong";
  const diffInMinutes = Math.floor(diffInSeconds / 60);
  if (diffInMinutes < 60) return `${diffInMinutes} phút trước`;
  const diffInHours = Math.floor(diffInMinutes / 60);
  if (diffInHours < 24) return `${diffInHours} giờ trước`;
  const diffInDays = Math.floor(diffInHours / 24);
  if (diffInSeconds < 0) return date.toLocaleDateString('vi-VN'); 
  return `${diffInDays} ngày trước`;
};

const formatCurrency = (amount) => {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount).replace('₫', 'đ');
};

const getAvatarColor = (name) => {
    const colors = ['bg-red-900', 'bg-blue-900', 'bg-emerald-900', 'bg-purple-900'];
    return colors[(name?.length || 0) % colors.length];
}

// === 2. MOCK DATA ===
const API_DATA = {
  users: [
    { id: "u1", username: "evangelion.eva011", nickname: "EVA.01(thám hiểm)", stats: "92.7K Followers • 449 Videos", avatar: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&h=100&fit=crop" },
    { id: "u2", username: "evangelionvn", nickname: "Evangelion-VN", stats: "17.6K Followers • 128 Videos", avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop" },
    { id: "u3", username: "bacsionline", nickname: "Dr. Strange", stats: "500K Followers • 12 Videos", avatar: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=100&h=100&fit=crop" }
  ],
  posts: [
    {
        id: "p1",
        userName: "NguyenVanB",
        title: "<h3><strong>Súp gà thảo dược</strong></h3>",
        content: "<p>Để sức khỏe của bệnh nhân hồi phục nhanh, súp gà sẽ là lựa chọn ưu tiên hàng đầu. Thịt gà chứa nhiều dinh dưỡng...</p>",
        image: "https://images.unsplash.com/photo-1547592166-23ac79cb621b?w=600&h=400&fit=crop",
        createdAt: "2025-05-21T02:09:08.6544666",
        likeCount: 120
    },
    {
        id: "p2",
        userName: "ngocphuc",
        title: "Review món Burger bò Mỹ",
        content: "Món này ngon thực sự mọi người ạ, phô mai tan chảy quyện với thịt bò nướng than thơm lừng...",
        image: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&h=400&fit=crop",
        createdAt: "2025-11-17T17:37:48.8289568",
        likeCount: 89
    },
    {
        id: "p3",
        userName: "BoyKa",
        title: "Sả - Thảo dược chữa bệnh",
        content: "Sả là gia vị quen thuộc trong món ăn Việt, đồng thời là dược liệu quý giúp giải cảm...",
        image: "https://images.unsplash.com/photo-1596547609652-9cf5d8d71321?w=600&h=400&fit=crop",
        createdAt: "2025-05-17T13:30:00",
        likeCount: 45
    },
    {
        id: "p4",
        userName: "LanHue",
        title: "Cách làm chè dưỡng nhan",
        content: "Chè dưỡng nhan tuyết yến nhựa đào giúp đẹp da, thanh mát cơ thể...",
        image: "https://images.unsplash.com/photo-1564834724105-918b73d1b9e0?w=600&h=400&fit=crop",
        createdAt: "2025-05-20T08:00:00",
        likeCount: 230
    }
  ],
  medicines: [
    { id: "m1", name: "Đinh Lăng ngâm rượu", description: "Rễ đinh lăng giúp bồi bổ khí huyết, tăng cường sinh lực và giảm mệt mỏi hiệu quả.", image: "https://images.unsplash.com/photo-1606914469725-e39c37155492?w=400&h=300&fit=crop", views: 732 },
    { id: "m2", name: "Trà hoa cúc", description: "Thanh nhiệt, giải độc, giúp ngủ ngon và giảm căng thẳng sau ngày dài.", image: "https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=400&h=300&fit=crop", views: 162 },
    { id: "m3", name: "Nấm linh chi đỏ", description: "Tăng cường hệ miễn dịch, ngăn ngừa lão hóa và hỗ trợ điều trị bệnh gan.", image: "https://images.unsplash.com/photo-1621795261888-64096e778b76?w=400&h=300&fit=crop", views: 540 },
    { id: "m4", name: "Hạt sen sấy khô", description: "Giúp an thần, ngủ ngon, bồi bổ cơ thể cho người mới ốm dậy.", image: "https://images.unsplash.com/photo-1600347363651-9d343c81b467?w=400&h=300&fit=crop", views: 320 },
    { id: "m5", name: "Táo đỏ Tân Cương", description: "Bổ máu, đẹp da, dùng pha trà hoặc nấu canh gà rất tốt.", image: "https://images.unsplash.com/photo-1589353869015-34d324295d18?w=400&h=300&fit=crop", views: 890 }
  ],
  dishes: [
    { id: "d1", name: "Cháo lươn Nghệ An", price: 120000, description: "Đặc sản xứ Nghệ với thịt lươn đồng xào nghệ vàng ươm, thơm lừng.", image: "https://i.ytimg.com/vi/tKf9qLDhaHk/hq720.jpg", category: "Đặc sản" },
    { id: "d2", name: "Canh riêu cua đồng", price: 65000, description: "Món canh giải nhiệt mùa hè, vị ngọt thanh mát từ cua đồng tươi.", image: "https://cdn.tgdd.vn/2021/04/CookRecipe/Avatar/canh-rieu-cua-nau-ngot-thumbnail.jpg", category: "Dân dã" },
    { id: "d3", name: "Cua hoàng đế hấp", price: 2500000, description: "Thượng hạng, thịt chắc ngọt, chế biến đơn giản giữ trọn hương vị.", image: "https://i.ytimg.com/vi/7yRxZk6dV1Y/hq720.jpg", category: "Thượng hạng" },
    { id: "d4", name: "Phở bò Nam Định", price: 50000, description: "Nước dùng đậm đà, bánh phở dai ngon, thịt bò mềm ngọt.", image: "https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=400&h=300&fit=crop", category: "Phổ biến" },
    { id: "d5", name: "Gỏi cuốn tôm thịt", price: 45000, description: "Món ăn nhẹ nhàng, chấm mắm nêm hoặc tương đậu đều ngon.", image: "https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=400&h=300&fit=crop", category: "Dân dã" }
  ]
};

export default function App() {
  const [activeTab, setActiveTab] = useState('Tất cả');
  const [following, setFollowing] = useState(new Set());
  
  // State cho bộ lọc
  const [filterCategory, setFilterCategory] = useState('Tất cả');
  const [sortOption, setSortOption] = useState('default'); // default, price_asc, price_desc, likes, views

  const tabs = ['Tất cả', 'Người dùng', 'Bài viết', 'Bài thuốc', 'Món ăn'];

  // Reset filter khi chuyển tab
  const handleTabChange = (tab) => {
    setActiveTab(tab);
    setFilterCategory('Tất cả');
    setSortOption('default');
  };

  const toggleFollow = (id) => {
    const newSet = new Set(following);
    if (newSet.has(id)) newSet.delete(id);
    else newSet.add(id);
    setFollowing(newSet);
  };

  // === LOGIC LỌC VÀ SẮP XẾP DỮ LIỆU ===
  const getFilteredData = () => {
    let result = { ...API_DATA };

    // 1. Lọc Món ăn
    if (activeTab === 'Món ăn') {
        let dishes = [...API_DATA.dishes];
        if (filterCategory !== 'Tất cả') {
            dishes = dishes.filter(d => d.category === filterCategory);
        }
        if (sortOption === 'price_asc') dishes.sort((a, b) => a.price - b.price);
        if (sortOption === 'price_desc') dishes.sort((a, b) => b.price - a.price);
        result.dishes = dishes;
    }

    // 2. Lọc Bài viết
    if (activeTab === 'Bài viết') {
        let posts = [...API_DATA.posts];
        if (sortOption === 'likes') posts.sort((a, b) => b.likeCount - a.likeCount);
        if (sortOption === 'newest') posts.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
        result.posts = posts;
    }

    // 3. Lọc Bài thuốc
    if (activeTab === 'Bài thuốc') {
        let medicines = [...API_DATA.medicines];
        if (sortOption === 'views') medicines.sort((a, b) => b.views - a.views);
        result.medicines = medicines;
    }

    return result;
  };

  const filteredData = getFilteredData();

  // === COMPONENTS CON ===

  // 1. User Item
  const UserItemTikTok = ({ user }) => (
    <div className="flex items-center justify-between py-3 px-4 hover:bg-gray-800/50 transition-colors">
      <div className="flex items-center gap-3">
        <div className="w-12 h-12 rounded-full overflow-hidden border border-gray-700">
          <img src={user.avatar} alt={user.username} className="w-full h-full object-cover" />
        </div>
        <div className="flex-col">
          <h3 className="text-gray-100 font-bold text-[15px] leading-tight mb-0.5">{user.username}</h3>
          <p className="text-gray-400 text-[13px] mb-0.5">{user.nickname}</p>
          <p className="text-gray-500 text-[11px]">{user.stats}</p>
        </div>
      </div>
      <button 
        onClick={() => toggleFollow(user.id)}
        className={`min-w-[80px] h-[34px] px-3 rounded-[4px] text-[14px] font-semibold flex items-center justify-center transition-all ${
          following.has(user.id) 
            ? 'bg-gray-800 text-white border border-gray-600' 
            : 'bg-[#FE2C55] text-white hover:bg-[#E6284C]'
        }`}
      >
        {following.has(user.id) ? 'Bạn bè' : 'Follow'}
      </button>
    </div>
  );

  // 2. Post Item (Updated: Transparent Background)
  const PostItemMagazine = ({ data }) => {
      let displayTitle = cleanContent(data.title);
      if (displayTitle.length > 100) displayTitle = displayTitle.substring(0, 80) + "...";
      
      let displayExcerpt = cleanContent(data.content);
      if (displayExcerpt.startsWith(displayTitle)) {
          displayExcerpt = displayExcerpt.substring(displayTitle.length).trim();
      }
      if (displayExcerpt.length > 120) displayExcerpt = displayExcerpt.substring(0, 120) + "...";
      
      const timeAgo = formatTimeAgo(data.createdAt);

      return (
        // Thay đổi bg-gray-900 thành bg-transparent
        <div className="bg-transparent border-b border-gray-800 p-4 active:bg-gray-800/30 transition-colors cursor-pointer group">
          {/* Header nhỏ */}
          <div className="flex items-center gap-2 mb-2">
            <div className={`w-5 h-5 rounded-full ${getAvatarColor(data.userName)} flex items-center justify-center ring-1 ring-gray-700`}>
               <span className="text-[10px] font-bold text-gray-200">{data.userName?.charAt(0).toUpperCase()}</span>
            </div>
            <span className="text-xs font-semibold text-gray-300">{data.userName}</span>
            <span className="text-gray-600 text-[10px]">•</span>
            <span className="text-xs text-gray-500">{timeAgo}</span>
          </div>

          <div className="flex gap-4">
            {/* Nội dung */}
            <div className="flex-1 min-w-0 flex flex-col justify-between">
              <div>
                <h3 className="text-gray-100 font-bold text-base leading-snug mb-1.5 line-clamp-2 group-hover:text-emerald-400 transition-colors">
                  {displayTitle}
                </h3>
                <p className="text-gray-400 text-sm line-clamp-2 leading-relaxed">
                  {displayExcerpt}
                </p>
              </div>
              
              {/* Actions */}
              <div className="flex items-center gap-4 mt-3">
                 <div className="flex items-center gap-1.5 text-gray-500 text-xs">
                    <Heart size={14} className="group-hover:text-pink-500 transition-colors"/> 
                    {data.likeCount || 0}
                 </div>
                 <div className="flex items-center gap-1.5 text-gray-500 text-xs">
                    <MessageCircle size={14} className="group-hover:text-blue-400 transition-colors"/> 
                    0
                 </div>
              </div>
            </div>

            {/* Ảnh Thumbnail */}
            {data.image && (
              <div className="w-24 h-24 sm:w-32 sm:h-24 flex-shrink-0">
                <img 
                  src={data.image} 
                  alt="thumbnail" 
                  className="w-full h-full object-cover rounded-xl border border-gray-800 shadow-sm"
                  onError={(e) => {e.target.style.display = 'none'}} 
                />
              </div>
            )}
          </div>
        </div>
      );
  };

  // 3. Grid Item
  const GridItem = ({ item, type }) => (
    <div className="bg-[#1E1E1E] rounded-xl overflow-hidden border border-gray-800 shadow-sm group relative flex flex-col h-full">
        <div className="aspect-square overflow-hidden relative flex-shrink-0">
            <img src={item.image} alt={item.name} className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110" />
            
            <button className="absolute top-2 right-2 p-1.5 bg-black/40 backdrop-blur-sm rounded-full text-white hover:bg-pink-500 transition-colors">
                <Heart size={14} />
            </button>

            {type === 'dish' && (
                <div className="absolute bottom-2 left-2 bg-emerald-600/90 text-white text-[10px] font-bold px-2 py-0.5 rounded-md shadow-sm">
                    {formatCurrency(item.price)}
                </div>
            )}
        </div>
        
        <div className="p-3 flex flex-col flex-1">
            <h3 className="text-gray-100 font-bold text-sm mb-1 line-clamp-2 leading-snug">{item.name}</h3>
            
            <p className="text-gray-400 text-xs line-clamp-2 mb-2 flex-1">{item.description}</p>
            
            {type === 'medicine' ? (
                <div className="flex items-center justify-between mt-auto pt-2 border-t border-gray-800">
                     <span className="text-[10px] text-gray-500 flex items-center gap-1">
                        <Eye size={12} /> {item.views}
                     </span>
                     <span className="text-[10px] text-emerald-500 font-medium bg-emerald-500/10 px-1.5 py-0.5 rounded">Dân gian</span>
                </div>
            ) : (
                <div className="flex items-center gap-1 mt-auto pt-2 text-[11px] text-gray-400 border-t border-gray-800">
                    <MapPin size={12} /> 
                    <span>{item.category}</span>
                </div>
            )}
        </div>
    </div>
  );

  // 4. Filter Chips Component
  const FilterBar = () => {
      if (activeTab === 'Tất cả' || activeTab === 'Người dùng') return null;

      return (
          <div className="flex items-center gap-2 px-4 py-2 overflow-x-auto no-scrollbar border-b border-gray-800 bg-black/50 backdrop-blur-sm sticky top-[105px] z-30">
              <SlidersHorizontal size={16} className="text-gray-500 flex-shrink-0 mr-1" />
              
              {/* Filters cho Món ăn */}
              {activeTab === 'Món ăn' && (
                  <>
                      {['Tất cả', 'Đặc sản', 'Dân dã', 'Thượng hạng', 'Phổ biến'].map(cat => (
                          <button 
                            key={cat}
                            onClick={() => setFilterCategory(cat)}
                            className={`whitespace-nowrap px-3 py-1 rounded-full text-xs font-medium border transition-colors ${
                                filterCategory === cat 
                                ? 'bg-emerald-600 border-emerald-600 text-white' 
                                : 'bg-transparent border-gray-700 text-gray-400 hover:border-gray-500'
                            }`}
                          >
                              {cat}
                          </button>
                      ))}
                      <div className="w-[1px] h-4 bg-gray-700 mx-1"></div>
                      <button onClick={() => setSortOption('price_asc')} className={`whitespace-nowrap px-3 py-1 rounded-full text-xs font-medium border ${sortOption === 'price_asc' ? 'bg-emerald-900/50 border-emerald-500 text-emerald-400' : 'border-gray-700 text-gray-400'}`}>Giá thấp</button>
                      <button onClick={() => setSortOption('price_desc')} className={`whitespace-nowrap px-3 py-1 rounded-full text-xs font-medium border ${sortOption === 'price_desc' ? 'bg-emerald-900/50 border-emerald-500 text-emerald-400' : 'border-gray-700 text-gray-400'}`}>Giá cao</button>
                  </>
              )}

              {/* Filters cho Bài viết */}
              {activeTab === 'Bài viết' && (
                  <>
                      <button onClick={() => setSortOption('default')} className={`whitespace-nowrap px-3 py-1 rounded-full text-xs font-medium border ${sortOption === 'default' ? 'bg-emerald-600 border-emerald-600 text-white' : 'border-gray-700 text-gray-400'}`}>Mặc định</button>
                      <button onClick={() => setSortOption('newest')} className={`whitespace-nowrap px-3 py-1 rounded-full text-xs font-medium border ${sortOption === 'newest' ? 'bg-emerald-600 border-emerald-600 text-white' : 'border-gray-700 text-gray-400'}`}>Mới nhất</button>
                      <button onClick={() => setSortOption('likes')} className={`whitespace-nowrap px-3 py-1 rounded-full text-xs font-medium border ${sortOption === 'likes' ? 'bg-emerald-600 border-emerald-600 text-white' : 'border-gray-700 text-gray-400'}`}>Nhiều Like</button>
                  </>
              )}

              {/* Filters cho Bài thuốc */}
              {activeTab === 'Bài thuốc' && (
                  <>
                       <button onClick={() => setSortOption('default')} className={`whitespace-nowrap px-3 py-1 rounded-full text-xs font-medium border ${sortOption === 'default' ? 'bg-emerald-600 border-emerald-600 text-white' : 'border-gray-700 text-gray-400'}`}>Mới nhất</button>
                       <button onClick={() => setSortOption('views')} className={`whitespace-nowrap px-3 py-1 rounded-full text-xs font-medium border ${sortOption === 'views' ? 'bg-emerald-600 border-emerald-600 text-white' : 'border-gray-700 text-gray-400'}`}>Xem nhiều</button>
                  </>
              )}
          </div>
      );
  }

  // === MAIN RENDER ===
  return (
    <div className="bg-black min-h-screen font-sans text-gray-200 max-w-md mx-auto border-x border-gray-800 shadow-2xl flex flex-col overflow-hidden">
      
      {/* Header */}
      <div className="bg-black px-4 py-3 flex items-center gap-3 sticky top-0 z-50 border-b border-gray-900">
        <button className="text-gray-400 hover:text-white"><ArrowLeft size={24} /></button>
        <div className="flex-1 bg-gray-900 rounded-full flex items-center px-4 py-2 gap-2 border border-transparent focus-within:border-emerald-500/50">
          <Search size={16} className="text-gray-500" />
          <input type="text" defaultValue="ngon" className="bg-transparent text-white text-sm flex-1 outline-none placeholder-gray-600" placeholder="Tìm kiếm..." />
          <X size={16} className="text-gray-500" />
        </div>
        <MoreVertical size={24} className="text-gray-400" />
      </div>

      {/* Tab Bar */}
      <div className="bg-black sticky top-[60px] z-40 border-b border-gray-800">
        <div className="flex items-center justify-between overflow-x-auto no-scrollbar px-2">
            {tabs.map((tab) => {
                const isActive = tab === activeTab;
                return (
                    <button 
                        key={tab} 
                        onClick={() => handleTabChange(tab)}
                        className={`whitespace-nowrap px-4 py-3 text-[14px] font-medium transition-colors relative ${isActive ? 'text-emerald-400' : 'text-gray-500'}`}
                    >
                        {tab}
                        {isActive && <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-1/2 h-[2px] bg-emerald-400 rounded-t-full shadow-[0_-2px_6px_rgba(52,211,153,0.5)]"></div>}
                    </button>
                )
            })}
        </div>
      </div>

      {/* Filter Bar (Chỉ hiện khi ở tab con) */}
      <FilterBar />

      {/* Content Scroll Area */}
      <div className="flex-1 overflow-y-auto pb-20 no-scrollbar">
        
        {/* === TAB: TẤT CẢ HOẶC NGƯỜI DÙNG === */}
        {(activeTab === 'Tất cả' || activeTab === 'Người dùng') && (
            <div className="mb-2 py-2">
                {activeTab === 'Tất cả' && <div className="px-4 py-2 text-xs font-bold text-gray-500 uppercase tracking-wider">Người dùng</div>}
                {API_DATA.users.map(user => <UserItemTikTok key={user.id} user={user} />)}
                {activeTab === 'Tất cả' && (
                     <button className="w-full py-3 text-center text-xs text-emerald-500 font-medium border-b border-gray-800 hover:bg-gray-900 transition-colors">Xem thêm người dùng</button>
                )}
            </div>
        )}

        {/* === TAB: TẤT CẢ HOẶC BÀI VIẾT === */}
        {(activeTab === 'Tất cả' || activeTab === 'Bài viết') && (
            <div className={`${activeTab === 'Tất cả' ? 'border-b border-gray-800 mb-2' : ''}`}>
                {activeTab === 'Tất cả' && (
                    <div className="px-4 py-3 text-[16px] font-bold text-gray-100 flex items-center justify-between">
                        Bài viết nổi bật
                        <ChevronRight size={18} className="text-gray-500"/>
                    </div>
                )}
                {/* Sử dụng filteredData.posts nếu đang ở tab Bài viết, ngược lại dùng data gốc */}
                {(activeTab === 'Bài viết' ? filteredData.posts : API_DATA.posts).map(post => (
                    <PostItemMagazine key={post.id} data={post} />
                ))}
            </div>
        )}

        {/* === TAB: TẤT CẢ HOẶC BÀI THUỐC === */}
        {(activeTab === 'Tất cả' || activeTab === 'Bài thuốc') && (
            <div className="mb-4 px-3">
                {activeTab === 'Tất cả' && (
                    <div className="flex items-center justify-between py-3 px-1">
                        <h2 className="text-[16px] font-bold text-gray-100">Bài thuốc dân gian</h2>
                        <ChevronRight size={18} className="text-gray-500"/>
                    </div>
                )}
                <div className={`grid grid-cols-2 gap-3 ${activeTab !== 'Tất cả' ? 'mt-3' : ''}`}>
                    {(activeTab === 'Bài thuốc' ? filteredData.medicines : API_DATA.medicines).map(item => (
                        <GridItem key={item.id} item={item} type="medicine" />
                    ))}
                </div>
            </div>
        )}

        {/* === TAB: TẤT CẢ HOẶC MÓN ĂN === */}
        {(activeTab === 'Tất cả' || activeTab === 'Món ăn') && (
            <div className={`mb-4 px-3 ${activeTab === 'Tất cả' ? 'border-t border-gray-800 pt-2' : ''}`}>
                {activeTab === 'Tất cả' && (
                    <div className="flex items-center justify-between py-3 px-1">
                        <h2 className="text-[16px] font-bold text-gray-100">Món ngon mỗi ngày</h2>
                        <ChevronRight size={18} className="text-gray-500"/>
                    </div>
                )}
                <div className={`grid grid-cols-2 gap-3 ${activeTab !== 'Tất cả' ? 'mt-3' : ''}`}>
                    {(activeTab === 'Món ăn' ? filteredData.dishes : API_DATA.dishes).map(item => (
                        <GridItem key={item.id} item={item} type="dish" />
                    ))}
                </div>
            </div>
        )}

      </div>

      {/* Bottom Nav */}
      <div className="bg-black border-t border-gray-800 h-[60px] flex justify-around items-center text-gray-500 sticky bottom-0 z-50">
            <div className="flex flex-col items-center gap-1 text-emerald-400">
                <Search size={22} strokeWidth={2.5} />
                <span className="text-[10px] font-medium">Khám phá</span>
            </div>
            <div className="flex flex-col items-center gap-1 hover:text-gray-300">
                <Heart size={22} />
                <span className="text-[10px] font-medium">Yêu thích</span>
            </div>
            <div className="flex flex-col items-center gap-1 hover:text-gray-300">
                <User size={22} />
                <span className="text-[10px] font-medium">Hồ sơ</span>
            </div>
      </div>

    </div>
  );
}