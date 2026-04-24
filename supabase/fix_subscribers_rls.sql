-- Activer le RLS sur la table subscribers
ALTER TABLE subscribers ENABLE ROW LEVEL SECURITY;

-- Créer une politique permettant à n'importe qui (même non authentifié) de s'inscrire
-- Note: 'anon' est le rôle utilisé pour les accès publics
DROP POLICY IF EXISTS "Allow public subscription" ON subscribers;
CREATE POLICY "Allow public subscription" 
ON subscribers 
FOR INSERT 
WITH CHECK (true);

-- Créer une politique permettant aux administrateurs de voir les abonnés
-- (Ajustez selon votre système d'authentification)
DROP POLICY IF EXISTS "Allow service role read" ON subscribers;
CREATE POLICY "Allow service role read" 
ON subscribers 
FOR SELECT 
USING (true);
