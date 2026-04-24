-- Enable realtime for support_messages
ALTER PUBLICATION supabase_realtime ADD TABLE public.support_messages;

-- Ensure RLS is enabled and policies are set if needed
ALTER TABLE public.support_messages ENABLE ROW LEVEL SECURITY;

-- Allow users to insert their own messages
CREATE POLICY "Users can insert own support messages" ON public.support_messages 
FOR INSERT WITH CHECK (auth.uid() = userid);

-- Allow users to see their own messages
CREATE POLICY "Users can see own support messages" ON public.support_messages 
FOR SELECT USING (auth.uid() = userid);

-- Allow admins to see all messages
CREATE POLICY "Admins can see all support messages" ON public.support_messages 
FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin')
);

-- Allow admins to insert replies
CREATE POLICY "Admins can insert support replies" ON public.support_messages 
FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.profiles WHERE uid = auth.uid() AND role = 'admin')
);
