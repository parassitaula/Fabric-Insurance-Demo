-- ============================================================
-- Fabric Insurance Demo - Warehouse Sample Queries (T-SQL)
-- Target: wh_insurance (Fabric Warehouse)
-- ============================================================
-- These queries use cross-database 3-part naming to read Silver
-- and Gold Delta tables directly from the Lakehouses:
--   lh_silver_insurance.dbo.<table>
--   lh_gold_insurance.dbo.<table>
-- No shortcuts are needed - Fabric Warehouses support cross-
-- database queries natively.
-- ============================================================


-- ============================================================
-- 1. Total Premium Revenue by Policy Type
-- ============================================================
SELECT
    p.policy_type,
    COUNT(DISTINCT p.policy_id)            AS policy_count,
    SUM(pr.amount_due)                     AS total_amount_due,
    SUM(pr.amount_paid)                    AS total_amount_paid,
    ROUND(SUM(pr.amount_paid) * 100.0
        / NULLIF(SUM(pr.amount_due), 0), 1) AS collection_rate_pct
FROM lh_silver_insurance.dbo.policies p
INNER JOIN lh_silver_insurance.dbo.premiums pr ON pr.policy_id = p.policy_id
GROUP BY p.policy_type
ORDER BY total_amount_paid DESC;


-- ============================================================
-- 2. Claims Count and Amount by Status
-- ============================================================
SELECT
    c.claim_status,
    COUNT(*)                               AS claim_count,
    SUM(c.estimated_amount)                AS total_estimated,
    AVG(c.estimated_amount)                AS avg_estimated,
    COALESCE(SUM(cp.payment_amount), 0)    AS total_paid
FROM lh_silver_insurance.dbo.claims c
LEFT JOIN (
    SELECT claim_id, SUM(payment_amount) AS payment_amount
    FROM lh_silver_insurance.dbo.claim_payments
    GROUP BY claim_id
) cp ON cp.claim_id = c.claim_id
GROUP BY c.claim_status
ORDER BY claim_count DESC;


-- ============================================================
-- 3. Customer Policy Portfolio Summary (Top 20)
-- ============================================================
SELECT TOP 20
    cu.customer_id,
    cu.first_name + ' ' + cu.last_name     AS customer_name,
    cu.city,
    cu.state,
    COUNT(DISTINCT p.policy_id)             AS total_policies,
    SUM(p.annual_premium)                   AS total_annual_premium,
    COUNT(DISTINCT cl.claim_id)             AS total_claims
FROM lh_silver_insurance.dbo.customers cu
INNER JOIN lh_silver_insurance.dbo.policies p ON p.customer_id = cu.customer_id
LEFT JOIN lh_silver_insurance.dbo.claims cl ON cl.policy_id = p.policy_id
GROUP BY cu.customer_id, cu.first_name, cu.last_name, cu.city, cu.state
ORDER BY total_annual_premium DESC;


-- ============================================================
-- 4. Premium Collection Rate by Billing Period
-- ============================================================
SELECT
    pr.billing_period,
    pr.payment_status,
    COUNT(*)                                AS premium_count,
    SUM(pr.amount_due)                      AS total_due,
    SUM(pr.amount_paid)                     AS total_paid,
    ROUND(SUM(pr.amount_paid) * 100.0
        / NULLIF(SUM(pr.amount_due), 0), 1) AS collection_rate_pct
FROM lh_silver_insurance.dbo.premiums pr
GROUP BY pr.billing_period, pr.payment_status
ORDER BY pr.billing_period, pr.payment_status;


-- ============================================================
-- 5. Loss Ratio Calculation
-- ============================================================
SELECT
    ROUND(
        COALESCE(SUM(cp.payment_amount), 0) * 100.0
        / NULLIF(
            (SELECT SUM(amount_paid) FROM lh_silver_insurance.dbo.premiums WHERE payment_status = 'paid'), 0
          ), 1
    ) AS loss_ratio_pct,
    COALESCE(SUM(cp.payment_amount), 0)         AS total_claim_payouts,
    (SELECT SUM(amount_paid) FROM lh_silver_insurance.dbo.premiums
     WHERE payment_status = 'paid')              AS total_premium_collected
FROM lh_silver_insurance.dbo.claim_payments cp;


-- ============================================================
-- 6. Top 10 Claims by Estimated Amount
-- ============================================================
SELECT TOP 10
    c.claim_id,
    c.policy_id,
    p.policy_type,
    c.claim_type,
    c.claim_status,
    c.date_of_loss,
    c.estimated_amount,
    COALESCE(pay.total_paid, 0)             AS total_paid,
    DATEDIFF(DAY, c.date_of_loss, c.date_filed) AS days_to_file
FROM lh_silver_insurance.dbo.claims c
INNER JOIN lh_silver_insurance.dbo.policies p ON p.policy_id = c.policy_id
LEFT JOIN (
    SELECT claim_id, SUM(payment_amount) AS total_paid
    FROM lh_silver_insurance.dbo.claim_payments
    GROUP BY claim_id
) pay ON pay.claim_id = c.claim_id
ORDER BY c.estimated_amount DESC;


-- ============================================================
-- 7. Agent Performance Metrics
-- ============================================================
SELECT
    a.agent_id,
    a.first_name + ' ' + a.last_name       AS agent_name,
    a.region,
    a.status                                AS agent_status,
    COUNT(DISTINCT p.policy_id)             AS policies_managed,
    SUM(p.annual_premium)                   AS total_annual_premium,
    COUNT(DISTINCT cl.claim_id)             AS total_claims,
    ROUND(
        COUNT(DISTINCT cl.claim_id) * 100.0
        / NULLIF(COUNT(DISTINCT p.policy_id), 0), 1
    )                                       AS claims_per_policy_pct
FROM lh_silver_insurance.dbo.agents a
LEFT JOIN lh_silver_insurance.dbo.policies p ON p.agent_id = a.agent_id
LEFT JOIN lh_silver_insurance.dbo.claims cl ON cl.policy_id = p.policy_id
GROUP BY a.agent_id, a.first_name, a.last_name, a.region, a.status
ORDER BY total_annual_premium DESC;


-- ============================================================
-- 8. Monthly Claims Trend
-- ============================================================
SELECT
    FORMAT(c.date_filed, 'yyyy-MM')         AS filed_month,
    c.claim_type,
    COUNT(*)                                AS claim_count,
    SUM(c.estimated_amount)                 AS total_estimated,
    AVG(c.estimated_amount)                 AS avg_estimated
FROM lh_silver_insurance.dbo.claims c
WHERE c.date_filed IS NOT NULL
GROUP BY FORMAT(c.date_filed, 'yyyy-MM'), c.claim_type
ORDER BY filed_month, c.claim_type;
