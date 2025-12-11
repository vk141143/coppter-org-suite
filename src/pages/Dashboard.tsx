import { DashboardLayout } from "@/components/layout/DashboardLayout";
import { StatCard } from "@/components/dashboard/StatCard";
import { ChartCard } from "@/components/dashboard/ChartCard";
import { Building2, Users, ClipboardCheck, Globe, TrendingUp } from "lucide-react";
import { motion } from "framer-motion";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Legend,
} from "recharts";

const countryData = [
  { name: "USA", value: 145 },
  { name: "UK", value: 89 },
  { name: "Germany", value: 67 },
  { name: "India", value: 156 },
  { name: "Australia", value: 43 },
  { name: "Canada", value: 52 },
];

const sizeData = [
  { name: "1-50", value: 120, fill: "hsl(200 80% 45%)" },
  { name: "51-200", value: 180, fill: "hsl(213 50% 23%)" },
  { name: "201-500", value: 95, fill: "hsl(160 84% 39%)" },
  { name: "500+", value: 45, fill: "hsl(43 96% 56%)" },
];

const recentOrganizations = [
  { name: "TechCorp Inc.", industry: "Technology", country: "USA", status: "active" },
  { name: "Global Finance Ltd.", industry: "Finance", country: "UK", status: "trial" },
  { name: "MediHealth Group", industry: "Healthcare", country: "Germany", status: "active" },
  { name: "EduLearn Systems", industry: "Education", country: "India", status: "pending" },
];

export default function Dashboard() {
  return (
    <DashboardLayout
      title="Dashboard"
      subtitle="Welcome back! Here's an overview of your platform."
    >
      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <StatCard
          title="Total Organizations"
          value="440"
          change="+12% from last month"
          changeType="positive"
          icon={Building2}
          iconColor="bg-primary/10 text-primary"
          delay={0}
        />
        <StatCard
          title="Total Employees"
          value="52,847"
          change="+8.3% from last month"
          changeType="positive"
          icon={Users}
          iconColor="bg-accent/10 text-accent"
          delay={0.1}
        />
        <StatCard
          title="Surveys Undertaken"
          value="1,284"
          change="+23% from last month"
          changeType="positive"
          icon={ClipboardCheck}
          iconColor="bg-success/10 text-success"
          delay={0.2}
        />
        <StatCard
          title="Active Countries"
          value="32"
          change="2 new this month"
          changeType="neutral"
          icon={Globe}
          iconColor="bg-warning/10 text-warning"
          delay={0.3}
        />
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <ChartCard
          title="Country-wise Distribution"
          subtitle="Organizations across different countries"
          delay={0.4}
        >
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={countryData} margin={{ top: 10, right: 10, left: -10, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
              <XAxis 
                dataKey="name" 
                tick={{ fill: "hsl(var(--muted-foreground))", fontSize: 12 }}
                axisLine={{ stroke: "hsl(var(--border))" }}
              />
              <YAxis 
                tick={{ fill: "hsl(var(--muted-foreground))", fontSize: 12 }}
                axisLine={{ stroke: "hsl(var(--border))" }}
              />
              <Tooltip
                contentStyle={{
                  backgroundColor: "hsl(var(--card))",
                  border: "1px solid hsl(var(--border))",
                  borderRadius: "8px",
                  boxShadow: "var(--shadow-lg)",
                }}
                labelStyle={{ color: "hsl(var(--foreground))" }}
              />
              <Bar 
                dataKey="value" 
                fill="hsl(var(--primary))" 
                radius={[4, 4, 0, 0]}
              />
            </BarChart>
          </ResponsiveContainer>
        </ChartCard>

        <ChartCard
          title="Organization Size Segmentation"
          subtitle="Distribution by employee count"
          delay={0.5}
        >
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie
                data={sizeData}
                cx="50%"
                cy="50%"
                innerRadius={70}
                outerRadius={100}
                paddingAngle={5}
                dataKey="value"
              >
                {sizeData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.fill} />
                ))}
              </Pie>
              <Tooltip
                contentStyle={{
                  backgroundColor: "hsl(var(--card))",
                  border: "1px solid hsl(var(--border))",
                  borderRadius: "8px",
                }}
              />
              <Legend 
                verticalAlign="bottom" 
                height={36}
                formatter={(value) => (
                  <span className="text-sm text-muted-foreground">{value} employees</span>
                )}
              />
            </PieChart>
          </ResponsiveContainer>
        </ChartCard>
      </div>

      {/* Recent Organizations */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.6 }}
        className="stat-card"
      >
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-lg font-semibold text-foreground">Recent Organizations</h3>
            <p className="text-sm text-muted-foreground">Latest organizations added to the platform</p>
          </div>
          <button className="btn-ghost text-primary">
            View All
            <TrendingUp className="w-4 h-4 ml-2" />
          </button>
        </div>

        <div className="overflow-x-auto">
          <table className="data-table">
            <thead>
              <tr>
                <th>Organization</th>
                <th>Industry</th>
                <th>Country</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {recentOrganizations.map((org, index) => (
                <motion.tr
                  key={org.name}
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.7 + index * 0.1 }}
                >
                  <td className="font-medium text-foreground">{org.name}</td>
                  <td className="text-muted-foreground">{org.industry}</td>
                  <td className="text-muted-foreground">{org.country}</td>
                  <td>
                    <span
                      className={`status-badge ${
                        org.status === "active"
                          ? "status-active"
                          : org.status === "trial"
                          ? "status-trial"
                          : "status-pending"
                      }`}
                    >
                      <span
                        className={`w-1.5 h-1.5 rounded-full mr-1.5 ${
                          org.status === "active"
                            ? "bg-success"
                            : org.status === "trial"
                            ? "bg-warning"
                            : "bg-muted-foreground"
                        }`}
                      />
                      {org.status.charAt(0).toUpperCase() + org.status.slice(1)}
                    </span>
                  </td>
                </motion.tr>
              ))}
            </tbody>
          </table>
        </div>
      </motion.div>
    </DashboardLayout>
  );
}
