-- Insurance Claims Analytics SQL
-- Tables: claims, claim_payments, policies, policyholders, vehicles

-- 1. Executive KPIs
SELECT COUNT(*) AS total_claims,
       SUM(CASE WHEN status='paid' THEN 1 ELSE 0 END) AS paid_claims,
       SUM(CASE WHEN status='denied' THEN 1 ELSE 0 END) AS denied_claims,
       SUM(CASE WHEN status IN ('filed','under_review','investigation') THEN 1 ELSE 0 END) AS open_claims,
       ROUND(SUM(claim_amount),2) AS total_claim_amount,
       ROUND(SUM(paid_total),2) AS total_paid,
       ROUND(SUM(reserve_amount),2) AS total_reserve,
       ROUND(AVG(claim_amount),2) AS avg_claim_amount,
       ROUND(100.0*SUM(CASE WHEN status='denied' THEN 1 ELSE 0 END)/COUNT(*),2) AS denial_rate_pct,
       ROUND(100.0*SUM(paid_total)/SUM(claim_amount),2) AS paid_to_claim_pct
FROM claims;

-- 2. Peril performance
SELECT peril, COUNT(*) AS claims, ROUND(SUM(claim_amount),2) AS claim_amount,
       ROUND(SUM(paid_total),2) AS paid_amount, ROUND(AVG(claim_amount),2) AS avg_claim,
       ROUND(100.0*SUM(paid_total)/SUM(claim_amount),2) AS paid_to_claim_pct
FROM claims GROUP BY peril ORDER BY claim_amount DESC;

-- 3. Geographic performance
SELECT loss_state, COUNT(*) AS claims, ROUND(SUM(claim_amount),2) AS claim_amount,
       ROUND(SUM(paid_total),2) AS paid_amount, ROUND(AVG(claim_amount),2) AS avg_claim
FROM claims GROUP BY loss_state ORDER BY claim_amount DESC;

-- 4. Coverage economics (directional proxy)
SELECT p.coverage, COUNT(c.claim_id) AS claims,
       COUNT(DISTINCT c.policy_id) AS policies_with_claims,
       ROUND(SUM(c.claim_amount),2) AS claim_amount,
       ROUND(SUM(c.paid_total),2) AS paid_amount,
       ROUND(SUM(p.annual_premium),2) AS annual_premium_base,
       ROUND(100.0*SUM(c.paid_total)/SUM(c.claim_amount),2) AS paid_to_claim_pct,
       ROUND(SUM(c.paid_total)/SUM(p.annual_premium),2) AS paid_to_premium_proxy
FROM claims c JOIN policies p ON c.policy_id=p.policy_id
GROUP BY p.coverage ORDER BY paid_to_premium_proxy DESC;

-- 5. Reserve backlog
SELECT status, COUNT(*) AS claims, ROUND(SUM(claim_amount),2) AS claim_amount,
       ROUND(SUM(reserve_amount),2) AS reserve,
       ROUND(100.0*SUM(reserve_amount)/NULLIF(SUM(claim_amount),0),2) AS reserve_to_claim_pct
FROM claims GROUP BY status ORDER BY reserve DESC;

-- 6. State x peril concentration
SELECT loss_state, peril, COUNT(*) AS claims,
       ROUND(SUM(claim_amount),2) AS claim_amount,
       ROUND(SUM(paid_total),2) AS paid_amount,
       ROUND(AVG(claim_amount),2) AS avg_claim
FROM claims GROUP BY loss_state, peril ORDER BY claim_amount DESC LIMIT 20;

-- 7. Payment method
SELECT method, COUNT(*) AS payments, ROUND(SUM(amount),2) AS cash_paid,
       ROUND(AVG(amount),2) AS avg_payment
FROM claim_payments GROUP BY method ORDER BY cash_paid DESC;

-- 8. Payment payee
SELECT payee, COUNT(*) AS payments, ROUND(SUM(amount),2) AS cash_paid,
       ROUND(AVG(amount),2) AS avg_payment
FROM claim_payments GROUP BY payee ORDER BY cash_paid DESC;

-- 9. Repeat-claim policyholders
SELECT ph.policyholder_id, ph.state, ph.credit_band, COUNT(c.claim_id) AS claims,
       ROUND(SUM(c.claim_amount),2) AS total_claim_amount,
       ROUND(SUM(c.paid_total),2) AS total_paid
FROM policyholders ph
JOIN policies p ON ph.policyholder_id=p.policyholder_id
JOIN claims c ON p.policy_id=c.policy_id
GROUP BY ph.policyholder_id, ph.state, ph.credit_band
HAVING COUNT(c.claim_id)>=5
ORDER BY claims DESC, total_claim_amount DESC LIMIT 100;

-- 10. Integrity checks
SELECT COUNT(*) AS claims,
       SUM(CASE WHEN date(c.loss_date)<date(p.start_date)
                  OR date(c.loss_date)>date(p.end_date) THEN 1 ELSE 0 END) AS outside_policy_period,
       SUM(CASE WHEN date(c.reported_on)<date(c.loss_date) THEN 1 ELSE 0 END) AS reported_before_loss
FROM claims c JOIN policies p ON c.policy_id=p.policy_id;
