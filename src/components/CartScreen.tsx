import {ArrowRight,Minus,Plus,Trash2,ShoppingBag} from 'lucide-react';
import type {CartItem} from '@/types';
import {formatYER} from '@/utils';
export default function CartScreen({items,onBack,onQty,onRemove,onLogin}:{items:CartItem[];onBack:()=>void;onQty:(id:string,q:number)=>void;onRemove:(id:string)=>void;onLogin:()=>void}){
 const total=items.reduce((s,x)=>s+(x.product?.price||0)*x.quantity,0);
 return <div className="animate-fade-in">
  <button onClick={onBack} className="mb-4 flex items-center gap-2 text-sm font-bold text-slate-600"><ArrowRight size={18}/>متابعة التسوق</button>
  <div className="mb-5 flex items-center gap-2"><ShoppingBag className="text-amber-500"/><h1 className="text-2xl font-black">سلة المشتريات</h1></div>
  {!items.length?<div className="rounded-3xl bg-white p-12 text-center shadow-sm"><ShoppingBag className="mx-auto mb-3 text-slate-300" size={42}/><p className="font-bold text-slate-500">السلة فارغة حاليًا</p><button onClick={onBack} className="mt-4 rounded-xl bg-amber-500 px-5 py-2 text-sm font-bold text-white">ابدأ التسوق</button></div>:<div className="space-y-4">
   {items.map(x=><div key={x.id} className="flex gap-3 rounded-2xl border bg-white p-3 shadow-sm"><img src={x.product?.image_url||'https://placehold.co/160x160?text=Solar'} className="h-20 w-20 rounded-xl object-cover"/><div className="min-w-0 flex-1"><b className="block truncate text-sm">{x.product?.name_ar}</b><span className="text-sm font-extrabold text-amber-600">{formatYER(x.product?.price||0)} ر.ي</span><div className="mt-2 flex items-center gap-3"><button onClick={()=>onQty(x.product_id,x.quantity-1)} className="rounded-lg border p-1"><Minus size={15}/></button><span className="min-w-5 text-center font-bold">{x.quantity}</span><button onClick={()=>onQty(x.product_id,x.quantity+1)} className="rounded-lg border p-1"><Plus size={15}/></button></div></div><button onClick={()=>onRemove(x.product_id)} className="self-start rounded-lg p-2 text-rose-500"><Trash2 size={18}/></button></div>)}
   <div className="rounded-3xl bg-slate-900 p-5 text-white"><div className="flex items-center justify-between"><span>الإجمالي</span><strong className="text-xl text-amber-400">{formatYER(total)} ر.ي</strong></div><p className="mt-2 text-xs text-slate-400">لا يشمل أجور التوصيل. تأكيد الطلب يتطلب تسجيل الدخول.</p><button onClick={onLogin} className="mt-4 w-full rounded-xl bg-amber-500 py-3 font-black text-slate-950">تسجيل الدخول لإكمال الطلب</button></div>
  </div>}
 </div>
}
