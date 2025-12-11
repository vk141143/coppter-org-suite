import { DashboardLayout } from "@/components/layout/DashboardLayout";
import { motion } from "framer-motion";
import { Users, Shield, Mail, UserPlus, MoreVertical, Search } from "lucide-react";
import { StatusBadge } from "@/components/ui/StatusBadge";

const users = [
  { id: 1, name: "Sarah Johnson", email: "sarah.j@coppter.com", role: "Super Admin", lastActive: "Just now", status: "active" },
  { id: 2, name: "Michael Chen", email: "m.chen@coppter.com", role: "Admin", lastActive: "2 hours ago", status: "active" },
  { id: 3, name: "Emily Rodriguez", email: "e.rodriguez@coppter.com", role: "Manager", lastActive: "1 day ago", status: "active" },
  { id: 4, name: "David Kim", email: "d.kim@coppter.com", role: "Viewer", lastActive: "3 days ago", status: "trial" },
];

const roles = [
  { name: "Super Admin", count: 2, permissions: "Full access to all features" },
  { name: "Admin", count: 5, permissions: "Manage organizations and users" },
  { name: "Manager", count: 12, permissions: "View and edit assigned organizations" },
  { name: "Viewer", count: 28, permissions: "Read-only access" },
];

export default function UserManagement() {
  return (
    <DashboardLayout
      title="User Management"
      subtitle="Manage platform users and their permissions"
    >
      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        {roles.map((role, index) => (
          <motion.div
            key={role.name}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.05 }}
            className="stat-card"
          >
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm font-medium text-muted-foreground">{role.name}</span>
              <Shield className="w-4 h-4 text-primary" />
            </div>
            <p className="text-2xl font-bold text-foreground">{role.count}</p>
            <p className="text-xs text-muted-foreground mt-1">{role.permissions}</p>
          </motion.div>
        ))}
      </div>

      {/* User List */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
        className="bg-card rounded-xl border border-border overflow-hidden"
      >
        <div className="p-6 border-b border-border">
          <div className="flex flex-col md:flex-row gap-4 justify-between">
            <div className="relative flex-1 max-w-md">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
              <input
                type="text"
                placeholder="Search users..."
                className="input-field pl-10"
              />
            </div>
            <div className="flex gap-2">
              <button className="btn-secondary gap-2">
                <Mail className="w-4 h-4" />
                Invite User
              </button>
              <button className="btn-primary gap-2">
                <UserPlus className="w-4 h-4" />
                Add User
              </button>
            </div>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="data-table">
            <thead>
              <tr>
                <th>User</th>
                <th>Role</th>
                <th>Last Active</th>
                <th>Status</th>
                <th className="text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {users.map((user, index) => (
                <motion.tr
                  key={user.id}
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.3 + index * 0.05 }}
                  className="group"
                >
                  <td>
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
                        <Users className="w-5 h-5 text-primary" />
                      </div>
                      <div>
                        <p className="font-medium text-foreground">{user.name}</p>
                        <p className="text-sm text-muted-foreground">{user.email}</p>
                      </div>
                    </div>
                  </td>
                  <td>
                    <span className={`text-sm font-medium ${
                      user.role === "Super Admin" ? "text-accent" : "text-foreground"
                    }`}>
                      {user.role}
                    </span>
                  </td>
                  <td className="text-muted-foreground">{user.lastActive}</td>
                  <td>
                    <StatusBadge status={user.status as "active" | "trial"} />
                  </td>
                  <td>
                    <div className="flex items-center justify-end">
                      <button className="p-2 rounded-lg hover:bg-muted opacity-0 group-hover:opacity-100 transition-all">
                        <MoreVertical className="w-4 h-4 text-muted-foreground" />
                      </button>
                    </div>
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
