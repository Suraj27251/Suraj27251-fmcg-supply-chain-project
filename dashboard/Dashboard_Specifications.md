# POWER BI DASHBOARD SPECIFICATIONS
## FMCG Order Fulfillment Performance & Target Analysis

**Dashboard Name:** FMCG Supply Chain Performance Dashboard
**Creator:** Supply Chain Analytics
**Last Updated:** April 2026
**Availability:** Internal - SharePoint integration

---

## DASHBOARD OVERVIEW

### Purpose
Real-time, comprehensive monitoring of order fulfillment performance across customers, products, and regions with drill-down capabilities for root cause analysis.

### Refresh Frequency
- **Data Refresh**: Daily (late night batch)
- **Dashboard Update**: Real-time query for last 90 days
- **Archive**: Monthly summary snapshots

### Target Users
- Executives (Summary view)
- Operations Managers (Detail view)
- Supply Chain Team (Deep dive)
- Sales Leadership (Customer view)

---

## PAGE 1: EXECUTIVE OVERVIEW (1 page)

### Layout: 4-4-2 grid

#### Top Row (KPI Cards - 4 columns)
1. **OTIF %**
   - Metric: ROUND(SUM(otif) / COUNT(*) * 100, 2)
   - Current Value: [Dynamic]
   - Previous Month: [Previous]
   - Trend: ↑↓ % change
   - Target: [Line]
   - Status Color: Red (<80%), Yellow (80-90%), Green (>90%)

2. **On-Time Delivery %**
   - Metric: ROUND(SUM(is_on_time) / COUNT(*) * 100, 2)
   - Gauge visualization showing 0-100%
   - Status indicator

3. **In-Full Delivery %**
   - Metric: ROUND(SUM(is_in_full) / COUNT(*) * 100, 2)
   - Similar gauge

4. **Target Achievement %**
   - Metric: (Current OTIF / Target OTIF) * 100
   - Status: Red if <90%, Yellow if 90-99%, Green if ≥100%

#### Second Row (Trend Charts - 4 columns)
1. **Monthly OTIF Trend** (Line chart)
   - X-axis: Months (last 12 months)
   - Y-axis: OTIF %
   - Series: Actual (blue), Target (red dashed)
   - Hover: Shows exact values

2. **On-Time vs In-Full Comparison** (Combo chart)
   - X-axis: Months
   - Y-axis %: Twin axes
   - Bars: On-Time (blue), In-Full (green)
   - Line: OTIF (red)

3. **Order Volume Trend** (Area chart)
   - Total orders per month
   - Color gradient: Light to dark

4. **Average Delay Trend** (Bar chart)
   - Days of delay per month
   - Red bars (above 0), showing negative days as positive

#### Third Row (Distribution & Analysis - 2 columns)
1. **OTIF Breakdown** (Donut chart)
   - Perfect (Green): [%]
   - Late Only (Orange): [%]
   - Partial Only (Blue): [%]
   - Both (Red): [%]
   - Legend with counts

2. **Dashboard Controls** (Slicer section)
   - Date Range Picker (Last 30/60/90/365 days)
   - Customer Filter (Multi-select)
   - Product Category Filter
   - Status: Apply button

#### Bottom Section
- **Key Insight Box**: 
  - "Current OTIF: [%]%, Target Gap: [%]%, Top Issue: [Inventory/Logistics/Combined]"
  - "Action Required: [X at-risk customers], [Y problem products]"

---

## PAGE 2: CUSTOMER INSIGHTS (Detail)

### Layout: 3-column + details

#### Left Column (Customer Selection)
**Customer List** (Interactive table with ranking)
- Rank
- Customer Name
- City
- OTIF % (conditional color)
- Gap to Target
- Segment (Champion / At-Risk / Potential / Low Priority)
- Sort options: By OTIF, By Value, By Gap

#### Middle Column (Selected Customer Metrics)
**Customer Card Dashboard**
- Customer Name (Large header)
- Total Orders
- Average OTIF %
- On-Time %, In-Full %
- Last order status
- Target vs Actual (gauge)
- Recent failures (count)

**Customer Trend** (Line chart)
- 12-month OTIF trend
- Comparison to overall avg

#### Right Column (Customer Performance Matrix)
**Scatter Plot: Value vs Performance**
- X-axis: Customer Value (Order Qty)
- Y-axis: OTIF %
- Quadrant lines: Median values
- Selected customer: Highlighted circle
- Other customers: Faded points
- Labels: Top 5 at-risk customers

#### Bottom Section
**Customer Order Details Table**
- Order ID
- Order Date
- Products Ordered
- Status (On-Time: ✓/✗, In-Full: ✓/✗)
- Delay Days
- Sort: By date, By status

### Additional Features
- **Drillthrough**: Click customer → Opens customer detail view
- **Bookmarks**: "Top 10 Customers", "At-Risk Only", "Champions Only"

---

## PAGE 3: PRODUCT ANALYSIS

### Layout: 3-column analysis

#### Left Column - Product Selection
**Product List** (Searchable table)
- Product Name
- Category
- OTIF %
- Avg Delay (days)
- Failure Count
- Sort: By OTIF, By Delays, By Failures

#### Middle Column - Product Performance
**Product Metrics Card**
- Product Name
- Category
- Total Orders
- OTIF %, On-Time %, In-Full %
- Average Delay
- Fulfillment Rate
- Orders with late delivery
- Orders with partial delivery

**Root Cause Breakdown** (Stacked bar)
- On-Time & In-Full: [%]
- Late Only: [%]
- Partial Only: [%]
- Both: [%]

#### Right Column - Multi-Product Comparison
**Category Performance Matrix** (Scatter)
- X-axis: Order Volume
- Y-axis: OTIF %
- Points: Each product
- Size: Order count
- Color: Category (legend)

**Top/Bottom Products** (Horizontal bar chart)
- Toggle: View top 10 or bottom 10
- Metrics: OTIF % with avg delay overlay
- Labels with product name, category

#### Bottom
**Product Order Details** (Table)
- Order ID
- Customer Name
- Order Date
- Qty Ordered / Delivered
- Delay Days
- Status badges

---

## PAGE 4: TARGET VS ACTUAL PERFORMANCE

### Layout: 2-column focused comparison

#### Left Column
**Target Achievement by Customer** (Scatter plot)
- X-axis: OTIF Target %
- Y-axis: Actual OTIF %
- Perfect line: Y=X (diagonal reference)
- Points: Each customer
  - Green: Above line (exceeding target)
  - Red: Below line (missing target)
  - Size: Customer value
- Annotations: Top performers, bottom performers

#### Right Column
**Gap Distribution** (Histogram)
- X-axis: Gap % (from -30% to +20%)
- Y-axis: Customers count
- Red bars: Below target (negative gap)
- Green bars: Above target
- Mean line: Average gap

**Gap Trend** (Line chart)
- Monthly avg gap trend
- Horizontal line: "0% gap" target
- Highlight: Improvement or worsening trend

#### Bottom Section
**Target Alignment Analysis** (Table)
- Customer Name
- On-Time Target vs Actual
- In-Full Target vs Actual
- OTIF Target vs Actual
- Overall Gap
- Trend: ↑↓
- Status: ✓ Meeting / ⚠️ Close / ✗ Missing

---

## PAGE 5: ROOT CAUSE & PARETO ANALYSIS

### Layout: 2-column deep-dive

#### Left Column

**Failure Root Causes** (Stacked horizontal bar)
- On-Time & In-Full: Green
- Late Only: Orange (Logistics)
- Partial Only: Blue (Inventory)
- Both: Red (Operations)
- Percentages and counts

**Root Cause by Customer** (Waterfall or horizontal stacked)
- Top 10 customers with failure types
- Shows split between logistics vs inventory issues

#### Right Column

**Pareto Analysis: Customers** (Combo chart)
- Bar: Failure count per customer (descending)
- Line: Cumulative % (right axis)
- Horizontal line: 80% mark
- Annotation: "Top [X]% of customers = 80% of failures"

**Pareto Analysis: Products** (Similar combo)
- Bar: Failure count per product
- Line: Cumulative % (right axis)
- Annotation: Shows how many of top products needed to hit 80%

#### Bottom Section
**Critical Items to Fix** (Priority table)
- Type: Customer / Product
- Name
- Current Failures
- Current OTIF %
- If Fixed, System OTIF would be +[%]%
- Priority Score (1-10)
- Recommended Action

### Filtering
- Toggle: Show by Customer / Product
- Date range selector
- Failure type filter

---

## PAGE 6: TIME ANALYSIS & SEASONALITY

### Layout: Time-focused

#### Top Section
**Monthly Performance Heatmap** (Table visualization)
- Rows: Months
- Columns: Metrics (Orders, OTIF %, On-Time %, In-Full %, Avg Delay)
- Color gradient: Red (poor) to Green (good)
- Values: Actual numbers + % of average

#### Middle Left
**Seasonal Pattern** (Line chart with variance)
- X-axis: Month (1-12)
- Y-axis: Average OTIF %
- Line: Mean performance
- Shaded area: ±1 standard deviation
- Data points: Individual years

#### Middle Right
**Day-of-Week Analysis** (Line chart)
- X-axis: Day of week (Mon-Sun)
- Y-axis: Avg OTIF %
- Alert: Highlight if certain days consistently underperform

#### Bottom
**Weekly Trend** (Area chart)
- X-axis: Week (last 26 weeks)
- Y-axis: Orders, OTIF %
- Areas: Order volume (light), OTIF trend (dark)
- Highlights: Best week, worst week, improvement areas

---

## PAGE 7: DETAILED ANALYTICS (Optional Deep Dive)

### Layout: Flexible analysis

#### Section 1: Customer-Product Interaction
**Worst Customer-Product Combinations** (Heat map)
- Rows: Top 15 customers
- Columns: Top 15 products
- Cell color: OTIF % (red to green)
- Cell value: OTIF %
- Helps identify systematic issues

#### Section 2: Geographic Analysis (if location data available)
**City-wise Performance** (Map + table)
- Map: Color by OTIF %
- Table: City, Orders, OTIF %, Issues
- Helps identify regional patterns

#### Section 3: Fulfillment Rate Analysis
**Fulfillment Distribution** (Histogram)
- X-axis: Fulfillment Rate (0-100%)
- Y-axis: Order count
- Bars: Colors for fulfillment quality
- Insight: Shows partial delivery frequency

---

## PAGE 8: MONITORING & ALERTS

### Layout: Alert-focused

#### Top Section
**Status Indicators**
- Overall Status: Green/Yellow/Red
- OTIF Status vs Target
- On-Time vs Target
- In-Full vs Target
- Issues Requiring Action (Count)

#### Middle Section
**SLA Breaches** (List with highlighting)
- Customer accounts below targets this month
- Products with recurring delays
- Critical shipments at risk
- New problem identified

#### Bottom Section
**Action Items** (Prioritized list)
- Priority / Customer / Issue / Recommended Action / Owner / Due Date
- Color-coded by urgency
- Links to detailed views

---

## TECHNICAL SPECIFICATIONS

### Data Source
- **Primary**: Fact_order_lines + Fact_orders_aggregate
- **Dimensions**: dim_customers, dim_products, dim_date, dim_targets_orders
- **Refresh**: Daily (scheduled refresh)

### Calculated Measures (DAX)

```dax
-- Overall OTIF
OTIF_Pct = DIVIDE(SUM(fact_order_lines[is_otif]), COALESCE(COUNT(fact_order_lines), 1)) * 100

-- On-Time %
OnTime_Pct = DIVIDE(SUM(fact_order_lines[is_on_time]), COALESCE(COUNT(fact_order_lines), 1)) * 100

-- In-Full %
InFull_Pct = DIVIDE(SUM(fact_order_lines[is_in_full]), COALESCE(COUNT(fact_order_lines), 1)) * 100

-- Target Gap
Target_Gap = [OTIF_Pct] - RELATED(dim_targets_orders[otif_target %])

-- Average Delay
Avg_Delay_Days = AVERAGE(fact_order_lines[delay_days])

-- Fulfillment Rate
Fulfillment_Rate = AVERAGE(fact_order_lines[fulfillment_rate])

-- Previous Month OTIF
OTIF_PrevMonth = CALCULATE([OTIF_Pct], DATEADD(dim_date[date], -1, MONTH))

-- YoY Comparison
OTIF_YoY = CALCULATE([OTIF_Pct], SAMEPERIODLASTYEAR(dim_date[date]))
```

### Slicers & Filters (All Pages)
- **Date Range**: Relative date slicer (Last 30/60/90/365 days, custom range)
- **Customer**: Multi-select list
- **Product Category**: Multi-select dropdown
- **City**: Multi-select (if available)
- **Region**: Multi-select (if available)

### Drill-Through Capabilities
- **Customer name** → Opens customer detail page
- **Product name** → Opens product detail page
- **Month** → Opens daily breakdown view

### Interactive Features
- **Bookmark navigation**: Executive / Operations / Deep Dive views
- **Sync slicers**: Selections across pages
- **Tooltips**: Hover for definitions and additional metrics
- **Conditional formatting**: Status indicators, variance highlighting

---

## DASHBOARD USAGE GUIDE

### For Executives (5-minute view)
1. Go to Page 1 (Overview)
2. Check OTIF vs Target
3. Review trend and key insight
4. Note action items on Page 8

### For Operations (20-minute review)
1. Page 1: Overall status
2. Page 2: Customer issues
3. Page 3: Product issues
4. Page 5: Root causes
5. Page 8: Action items

### For Supply Chain Deep Dive (30+ minute analysis)
1. All pages systematically
2. Focus on Page 4-7 for detailed analysis
3. Cross-reference customers and products
4. Use Pareto insights for improvement prioritization

---

## FUTURE ENHANCEMENTS

- Predictive analytics for demand forecasting
- Vendor performance scorecard integration
- Cost-benefit analysis for improvements
- Mobile app version for on-the-go monitoring
- Automated anomaly detection and alerting
- AI-powered root cause explanation
- Scenario planning (what-if analysis)

---

*Dashboard should be published to Power BI Service and shared via email/link to stakeholders*
*Refresh schedule: Daily at 2 AM
*Access: Read-only for most users, edit access for analytics team*
