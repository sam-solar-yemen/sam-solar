import{useCallback,useEffect,useState}from'react';import{supabase}from'@/supabase';import type{Customer}from'@/types';
export function useAuth(){const[customer,setCustomer]=useState<Customer|null>(null);const[loading,setLoading]=useState(true);
 const load=useCallback(async(uid:string)=>{const{data}=await supabase.from('customers').select('*').eq('user_id',uid).maybeSingle();setCustomer(data as Customer|null);setLoading(false)},[]);
 useEffect(()=>{supabase.auth.getSession().then(({data})=>data.session?load(data.session.user.id):setLoading(false));const{data}=supabase.auth.onAuthStateChange((_e,s)=>{if(s)load(s.user.id);else{setCustomer(null);setLoading(false)}});return()=>data.subscription.unsubscribe()},[load]);
 const signIn=(email:string,password:string)=>supabase.auth.signInWithPassword({email,password});
 const signUp=async(email:string,password:string,name:string,phone='')=>{const r=await supabase.auth.signUp({email,password});if(!r.error&&r.data.user)await supabase.from('customers').insert({user_id:r.data.user.id,email,full_name_ar:name,phone,is_active:true});return r};
 const signOut=()=>supabase.auth.signOut();return{customer,loading,signIn,signUp,signOut}}
