import { DashboardLayout } from "@/components/layout/DashboardLayout";
import { motion } from "framer-motion";
import {
  CreditCard,
  Calendar,
  Check,
  ArrowUpRight,
  ArrowDownRight,
  Download,
  RefreshCw,
  AlertCircle,
} from "lucide-react";

const invoices = [
  { id: "INV-001", date: "Dec 1, 2024", amount: "$199.00", status: "paid", method: "Credit Card" },
  { id: "INV-002", date: "Nov 1, 2024", amount: "$199.00", status: "paid", method: "Credit Card" },
  { id: "INV-003", date: "Oct 1, 2024", amount: "$199.00", status: "paid", method: "Bank Transfer" },
  { id: "INV-004", date: "Sep 1, 2024", amount: "$79.00", status: "paid", method: "Credit Card" },
];

export default function Billing() {
  return (
    <DashboardLayout
      title="Subscription & Billing"
      subtitle="Manage subscription plans and payment history"
    >
      {/* Current Plan Overview */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="lg:col-span-2 stat-card"
        >
          <div className="flex items-start justify-between mb-6">
            <div>
              <span className="status-badge status-active mb-2">
                <span className="w-1.5 h-1.5 rounded-full bg-success mr-1.5" />
                Active Subscription
              </span>
              <h2 className="text-2xl font-bold text-foreground">Premium Plan</h2>
              <p className="text-muted-foreground">Unlimited users • All features included</p>
            </div>
            <div className="text-right">
              <p className="text-3xl font-bold text-foreground">$199</p>
              <p className="text-muted-foreground">per month</p>
            </div>
          </div>

          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
            <div className="p-4 rounded-lg bg-muted/50">
              <p className="text-sm text-muted-foreground">Active Users</p>
              <p className="text-xl font-bold text-foreground">2,847</p>
              <p className="text-xs text-muted-foreground">of unlimited</p>
            </div>
            <div className="p-4 rounded-lg bg-muted/50">
              <p className="text-sm text-muted-foreground">Locations</p>
              <p className="text-xl font-bold text-foreground">12</p>
              <p className="text-xs text-muted-foreground">of unlimited</p>
            </div>
            <div className="p-4 rounded-lg bg-muted/50">
              <p className="text-sm text-muted-foreground">API Calls</p>
              <p className="text-xl font-bold text-foreground">125K</p>
              <p className="text-xs text-success">+12% this month</p>
            </div>
            <div className="p-4 rounded-lg bg-muted/50">
              <p className="text-sm text-muted-foreground">Storage Used</p>
              <p className="text-xl font-bold text-foreground">48GB</p>
              <p className="text-xs text-muted-foreground">of 100GB</p>
            </div>
          </div>

          <div className="flex gap-3">
            <button className="btn-primary gap-2">
              <ArrowUpRight className="w-4 h-4" />
              Upgrade Plan
            </button>
            <button className="btn-secondary gap-2">
              <ArrowDownRight className="w-4 h-4" />
              Downgrade
            </button>
            <button className="btn-ghost gap-2 text-muted-foreground">
              <RefreshCw className="w-4 h-4" />
              Renew Now
            </button>
          </div>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="stat-card"
        >
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-lg bg-warning/10 flex items-center justify-center">
              <Calendar className="w-5 h-5 text-warning" />
            </div>
            <h3 className="font-semibold text-foreground">Billing Cycle</h3>
          </div>

          <div className="space-y-4">
            <div className="flex justify-between items-center">
              <span className="text-muted-foreground">Current Period</span>
              <span className="font-medium text-foreground">Dec 1 - Dec 31, 2024</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-muted-foreground">Next Billing</span>
              <span className="font-medium text-foreground">Jan 1, 2025</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-muted-foreground">Amount Due</span>
              <span className="font-medium text-foreground">$199.00</span>
            </div>

            <div className="pt-4 border-t border-border">
              <div className="flex items-center gap-2 text-sm text-success">
                <Check className="w-4 h-4" />
                Auto-renewal enabled
              </div>
            </div>
          </div>
        </motion.div>
      </div>

      {/* Billing History */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
        className="bg-card rounded-xl border border-border overflow-hidden"
      >
        <div className="p-6 border-b border-border">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-lg font-semibold text-foreground">Billing History</h3>
              <p className="text-sm text-muted-foreground">Download invoices and view payment history</p>
            </div>
            <button className="btn-secondary gap-2">
              <Download className="w-4 h-4" />
              Export All
            </button>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="data-table">
            <thead>
              <tr>
                <th>Invoice</th>
                <th>Date</th>
                <th>Amount</th>
                <th>Status</th>
                <th>Payment Method</th>
                <th className="text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {invoices.map((invoice, index) => (
                <motion.tr
                  key={invoice.id}
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.3 + index * 0.05 }}
                  className="group"
                >
                  <td className="font-mono text-sm font-medium text-foreground">{invoice.id}</td>
                  <td className="text-muted-foreground">{invoice.date}</td>
                  <td className="font-medium text-foreground">{invoice.amount}</td>
                  <td>
                    <span className="status-badge status-active">
                      <span className="w-1.5 h-1.5 rounded-full bg-success mr-1.5" />
                      Paid
                    </span>
                  </td>
                  <td className="text-muted-foreground flex items-center gap-2">
                    <CreditCard className="w-4 h-4" />
                    {invoice.method}
                  </td>
                  <td>
                    <div className="flex items-center justify-end">
                      <button className="btn-ghost text-sm py-1.5 gap-1.5">
                        <Download className="w-4 h-4" />
                        Download
                      </button>
                    </div>
                  </td>
                </motion.tr>
              ))}
            </tbody>
          </table>
        </div>
      </motion.div>

      {/* Renewal Reminder */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4 }}
        className="mt-6 p-4 rounded-xl bg-info/10 border border-info/20 flex items-start gap-4"
      >
        <div className="w-10 h-10 rounded-lg bg-info/20 flex items-center justify-center flex-shrink-0">
          <AlertCircle className="w-5 h-5 text-info" />
        </div>
        <div>
          <h4 className="font-semibold text-foreground">Subscription Renewal</h4>
          <p className="text-sm text-muted-foreground mt-1">
            Your subscription will automatically renew on January 1, 2025. The payment of $199.00 will be charged to your default payment method.
            You can manage your payment settings or cancel anytime before the renewal date.
          </p>
        </div>
      </motion.div>
    </DashboardLayout>
  );
}
