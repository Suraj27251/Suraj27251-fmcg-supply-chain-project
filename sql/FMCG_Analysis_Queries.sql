-- ============================================================================
-- FMCG ORDER FULFILLMENT PERFORMANCE & TARGET ANALYSIS
-- SQL QUERY SUITE FOR COMPREHENSIVE ANALYSIS
-- ============================================================================

-- ============================================================================
-- 1. OVERALL KPI METRICS
-- ============================================================================

-- 1.1 Global OTIF, On-Time, and In-Full Metrics
SELECT 
    COUNT(DISTINCT order_id) as total_orders,
    COUNT(*) as total_order_lines,
    SUM(order_qty) as total_qty_ordered,
    SUM(delivered_qty) as total_qty_delivered,
    ROUND(SUM(CASE WHEN actual_delivery_date <= agreed_delivery_date THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as on_time_pct,
    ROUND(SUM(CASE WHEN delivered_qty >= order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as in_full_pct,
    ROUND(SUM(CASE WHEN actual_delivery_date <= agreed_delivery_date AND delivered_qty >= order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as otif_pct,
    ROUND(AVG(CAST(actual_delivery_date - agreed_delivery_date AS FLOAT)), 2) as avg_delay_days
FROM fact_order_lines;

-- ============================================================================
-- 2. CUSTOMER-LEVEL ANALYSIS
-- ============================================================================

-- 2.1 OTIF by Customer with Target Comparison
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    COUNT(DISTINCT f.order_id) as total_orders,
    COUNT(*) as order_lines,
    ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as on_time_pct,
    ROUND(SUM(CASE WHEN f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as in_full_pct,
    ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date AND f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as otif_pct,
    t.[otif_target %] as otif_target,
    ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date AND f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) - t.[otif_target %] as otif_gap,
    SUM(f.order_qty) as total_qty_ordered,
    SUM(f.delivered_qty) as total_qty_delivered,
    ROUND(AVG(CAST(f.delivered_qty AS FLOAT) / f.order_qty), 4) as avg_fulfillment_rate
FROM fact_order_lines f
JOIN dim_customers c ON f.customer_id = c.customer_id
LEFT JOIN dim_targets_orders t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.customer_name, c.city, t.[otif_target %]
ORDER BY otif_pct ASC;

-- 2.2 Customers Missing OTIF Target (Critical List)
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    COUNT(DISTINCT f.order_id) as total_orders,
    t.[otif_target %] as target,
    ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date AND f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as actual_otif_pct,
    ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date AND f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) - t.[otif_target %] as gap
FROM fact_order_lines f
JOIN dim_customers c ON f.customer_id = c.customer_id
LEFT JOIN dim_targets_orders t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.customer_name, c.city, t.[otif_target %]
HAVING ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date AND f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) < COALESCE(t.[otif_target %], 90)
ORDER BY gap ASC;

-- 2.3 Customer Segmentation: Value vs Performance
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    SUM(f.order_qty) as customer_value,
    ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date AND f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as otif_pct,
    CASE 
        WHEN SUM(f.order_qty) > (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY SUM(order_qty)) FROM fact_order_lines GROUP BY customer_id)
         AND ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date AND f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) > (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date AND f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)) FROM fact_order_lines GROUP BY customer_id)
            THEN 'Champions'
        WHEN SUM(f.order_qty) > (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY SUM(order_qty)) FROM fact_order_lines GROUP BY customer_id)
            THEN 'At-Risk'
        WHEN ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date AND f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) > (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date AND f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)) FROM fact_order_lines GROUP BY customer_id)
            THEN 'Potential'
        ELSE 'Low Priority'
    END as segment
FROM fact_order_lines f
JOIN dim_customers c ON f.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.city
ORDER BY customer_value DESC;

-- ============================================================================
-- 3. PRODUCT-LEVEL ANALYSIS
-- ============================================================================

-- 3.1 OTIF by Product with Category
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    COUNT(DISTINCT f.order_id) as total_orders,
    COUNT(*) as order_lines,
    ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as on_time_pct,
    ROUND(SUM(CASE WHEN f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as in_full_pct,
    ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date AND f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as otif_pct,
    ROUND(AVG(CAST(f.actual_delivery_date - f.agreed_delivery_date AS FLOAT)), 2) as avg_delay_days,
    ROUND(AVG(CAST(f.delivered_qty AS FLOAT) / f.order_qty), 4) as avg_fulfillment_rate
FROM fact_order_lines f
JOIN dim_products p ON f.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY otif_pct ASC;

-- 3.2 Top Products by Delay Issues
SELECT TOP 15
    p.product_id,
    p.product_name,
    p.category,
    COUNT(*) as order_lines_delayed,
    ROUND(AVG(CAST(f.actual_delivery_date - f.agreed_delivery_date AS FLOAT)), 2) as avg_delay_days,
    MAX(DATEDIFF(DAY, f.agreed_delivery_date, f.actual_delivery_date)) as max_delay_days,
    ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as on_time_pct
FROM fact_order_lines f
JOIN dim_products p ON f.product_id = p.product_id
WHERE f.actual_delivery_date > f.agreed_delivery_date
GROUP BY p.product_id, p.product_name, p.category
ORDER BY avg_delay_days DESC;

-- 3.3 Category-wise Performance Summary
SELECT 
    p.category,
    COUNT(DISTINCT f.order_id) as total_orders,
    COUNT(*) as order_lines,
    ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as on_time_pct,
    ROUND(SUM(CASE WHEN f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as in_full_pct,
    ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date AND f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as otif_pct
FROM fact_order_lines f
JOIN dim_products p ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY otif_pct ASC;

-- ============================================================================
-- 4. TIME-BASED ANALYSIS
-- ============================================================================

-- 4.1 Monthly OTIF Trends
SELECT 
    d.mmm_yy as month,
    COUNT(DISTINCT f.order_id) as total_orders,
    SUM(f.order_qty) as total_qty_ordered,
    SUM(f.delivered_qty) as total_qty_delivered,
    ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as on_time_pct,
    ROUND(SUM(CASE WHEN f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as in_full_pct,
    ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date AND f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as otif_pct,
    ROUND(AVG(CAST(f.actual_delivery_date - f.agreed_delivery_date AS FLOAT)), 2) as avg_delay_days
FROM fact_order_lines f
JOIN dim_date d ON CONVERT(DATE, f.order_placement_date) = CAST(d.date AS DATE)
GROUP BY d.mmm_yy
ORDER BY d.mmm_yy;

-- 4.2 Week-over-Week Performance
SELECT 
    d.week_no,
    COUNT(DISTINCT f.order_id) as total_orders,
    ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date AND f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as otif_pct,
    ROUND(AVG(CAST(f.actual_delivery_date - f.agreed_delivery_date AS FLOAT)), 2) as avg_delay
FROM fact_order_lines f
JOIN dim_date d ON CONVERT(DATE, f.order_placement_date) = CAST(d.date AS DATE)
GROUP BY d.week_no
ORDER BY d.week_no;

-- ============================================================================
-- 5. ROOT CAUSE ANALYSIS
-- ============================================================================

-- 5.1 Failure Breakdown Analysis
SELECT 
    'Perfect (OTIF)' as failure_type,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_order_lines), 2) as pct_of_total
FROM fact_order_lines
WHERE actual_delivery_date <= agreed_delivery_date AND delivered_qty >= order_qty

UNION ALL

SELECT 
    'Late Delivery Only' as failure_type,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_order_lines), 2) as pct_of_total
FROM fact_order_lines
WHERE actual_delivery_date > agreed_delivery_date AND delivered_qty >= order_qty

UNION ALL

SELECT 
    'Partial Delivery Only' as failure_type,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_order_lines), 2) as pct_of_total
FROM fact_order_lines
WHERE actual_delivery_date <= agreed_delivery_date AND delivered_qty < order_qty

UNION ALL

SELECT 
    'Both Late & Partial' as failure_type,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_order_lines), 2) as pct_of_total
FROM fact_order_lines
WHERE actual_delivery_date > agreed_delivery_date AND delivered_qty < order_qty;

-- 5.2 Root Cause by Customer
SELECT TOP 20
    c.customer_id,
    c.customer_name,
    SUM(CASE WHEN f.actual_delivery_date > f.agreed_delivery_date AND f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) as late_only,
    SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date AND f.delivered_qty < f.order_qty THEN 1 ELSE 0 END) as partial_only,
    SUM(CASE WHEN f.actual_delivery_date > f.agreed_delivery_date AND f.delivered_qty < f.order_qty THEN 1 ELSE 0 END) as both_issues
FROM fact_order_lines f
JOIN dim_customers c ON f.customer_id = c.customer_id
WHERE f.actual_delivery_date > f.agreed_delivery_date OR f.delivered_qty < f.order_qty
GROUP BY c.customer_id, c.customer_name
ORDER BY (late_only + partial_only + both_issues) DESC;

-- ============================================================================
-- 6. PARETO ANALYSIS (80/20 RULE)
-- ============================================================================

-- 6.1 Customers Causing 80% of Issues
SELECT TOP 50
    c.customer_id,
    c.customer_name,
    COUNT(*) as order_lines_failed,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_order_lines WHERE actual_delivery_date > agreed_delivery_date OR delivered_qty < order_qty), 2) as pct_of_failures,
    SUM(COUNT(*)) OVER (ORDER BY COUNT(*) DESC) as cumulative_failures,
    ROUND(SUM(COUNT(*)) OVER (ORDER BY COUNT(*) DESC) * 100.0 / (SELECT COUNT(*) FROM fact_order_lines WHERE actual_delivery_date > agreed_delivery_date OR delivered_qty < order_qty), 2) as cumulative_pct
FROM fact_order_lines f
JOIN dim_customers c ON f.customer_id = c.customer_id
WHERE f.actual_delivery_date > f.agreed_delivery_date OR f.delivered_qty < f.order_qty
GROUP BY c.customer_id, c.customer_name
ORDER BY order_lines_failed DESC;

-- 6.2 Products Causing 80% of Issues
SELECT TOP 50
    p.product_id,
    p.product_name,
    p.category,
    COUNT(*) as order_lines_failed,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_order_lines WHERE actual_delivery_date > agreed_delivery_date OR delivered_qty < order_qty), 2) as pct_of_failures
FROM fact_order_lines f
JOIN dim_products p ON f.product_id = p.product_id
WHERE f.actual_delivery_date > f.agreed_delivery_date OR f.delivered_qty < f.order_qty
GROUP BY p.product_id, p.product_name, p.category
ORDER BY order_lines_failed DESC;

-- ============================================================================
-- 7. TARGET PERFORMANCE ANALYSIS
-- ============================================================================

-- 7.1 Target vs Actual by Customer
SELECT 
    c.customer_id,
    c.customer_name,
    t.[ontime_target %] as ontime_target,
    t.[infull_target %] as infull_target,
    t.[otif_target %] as otif_target,
    ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as actual_ontime,
    ROUND(SUM(CASE WHEN f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as actual_infull,
    ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date AND f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as actual_otif,
    ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date AND f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) - t.[otif_target %] as otif_gap
FROM fact_order_lines f
JOIN dim_customers c ON f.customer_id = c.customer_id
LEFT JOIN dim_targets_orders t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.customer_name, t.[ontime_target %], t.[infull_target %], t.[otif_target %]
ORDER BY actual_otif ASC;

-- 7.2 Overall Target Achievement
SELECT 
    (SELECT ROUND(AVG([ontime_target %]), 2) FROM dim_targets_orders) as avg_ontime_target,
    (SELECT ROUND(AVG([infull_target %]), 2) FROM dim_targets_orders) as avg_infull_target,
    (SELECT ROUND(AVG([otif_target %]), 2) FROM dim_targets_orders) as avg_otif_target,
    (SELECT ROUND(SUM(CASE WHEN actual_delivery_date <= agreed_delivery_date THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) FROM fact_order_lines) as actual_ontime,
    (SELECT ROUND(SUM(CASE WHEN delivered_qty >= order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) FROM fact_order_lines) as actual_infull,
    (SELECT ROUND(SUM(CASE WHEN actual_delivery_date <= agreed_delivery_date AND delivered_qty >= order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) FROM fact_order_lines) as actual_otif;

-- ============================================================================
-- 8. CUSTOMER-PRODUCT INTERACTION ANALYSIS
-- ============================================================================

-- 8.1 Worst performing Customer-Product combinations
SELECT TOP 25
    c.customer_id,
    c.customer_name,
    p.product_id,
    p.product_name,
    COUNT(*) as order_lines,
    ROUND(SUM(CASE WHEN f.actual_delivery_date <= f.agreed_delivery_date AND f.delivered_qty >= f.order_qty THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as otif_pct
FROM fact_order_lines f
JOIN dim_customers c ON f.customer_id = c.customer_id
JOIN dim_products p ON f.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name, p.product_id, p.product_name
HAVING COUNT(*) >= 5  -- Only combinations with at least 5 orders
ORDER BY otif_pct ASC, COUNT(*) DESC;

-- ============================================================================
-- END OF SQL QUERY SUITE
-- ============================================================================
