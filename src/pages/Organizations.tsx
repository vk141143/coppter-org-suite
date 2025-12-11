import { useState } from "react";
import { DashboardLayout } from "@/components/layout/DashboardLayout";
import { StatusBadge } from "@/components/ui/StatusBadge";
import { motion } from "framer-motion";
import { useNavigate } from "react-router-dom";
import {
  Search,
  Plus,
  Filter,
  MoreVertical,
  Eye,
  Pencil,
  Settings,
  ChevronLeft,
  ChevronRight,
  Building2,
} from "lucide-react";

type OrgStatus = "active" | "trial" | "expired";

interface Organization {
  id: string;
  name: string;
  industry: string;
  country: string;
  status: OrgStatus;
  plan: string;
  employees: number;
}

const organizations: Organization[] = [
  { id: "1", name: "TechCorp Industries", industry: "Technology", country: "United States", status: "active", plan: "Premium", employees: 2500 },
  { id: "2", name: "Global Finance Ltd", industry: "Finance", country: "United Kingdom", status: "active", plan: "Standard", employees: 850 },
  { id: "3", name: "MediHealth Group", industry: "Healthcare", country: "Germany", status: "trial", plan: "Premium", employees: 1200 },
  { id: "4", name: "EduLearn Systems", industry: "Education", country: "India", status: "active", plan: "Basic", employees: 320 },
  { id: "5", name: "RetailMax Corp", industry: "Retail", country: "Canada", status: "expired", plan: "Standard", employees: 4500 },
  { id: "6", name: "AutoMotion Inc", industry: "Manufacturing", country: "Japan", status: "active", plan: "Premium", employees: 3200 },
  { id: "7", name: "GreenEnergy Solutions", industry: "Energy", country: "Australia", status: "trial", plan: "Standard", employees: 180 },
  { id: "8", name: "DataDriven Analytics", industry: "Technology", country: "United States", status: "active", plan: "Premium", employees: 450 },
];

export default function Organizations() {
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedStatus, setSelectedStatus] = useState<string>("all");
  const navigate = useNavigate();

  const filteredOrgs = organizations.filter((org) => {
    const matchesSearch = org.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      org.industry.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus = selectedStatus === "all" || org.status === selectedStatus;
    return matchesSearch && matchesStatus;
  });

  return (
    <DashboardLayout
      title="Organisation Management"
      subtitle="Manage and monitor all organizations on the platform"
    >
      {/* Toolbar */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="flex flex-col md:flex-row gap-4 mb-6"
      >
        {/* Search */}
        <div className="relative flex-1">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
          <input
            type="text"
            placeholder="Search organizations by name, industry..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="input-field pl-12"
          />
        </div>

        {/* Filters */}
        <div className="flex gap-3">
          <select
            value={selectedStatus}
            onChange={(e) => setSelectedStatus(e.target.value)}
            className="input-field w-40"
          >
            <option value="all">All Status</option>
            <option value="active">Active</option>
            <option value="trial">Trial</option>
            <option value="expired">Expired</option>
          </select>

          <button className="btn-secondary gap-2">
            <Filter className="w-4 h-4" />
            <span className="hidden sm:inline">More Filters</span>
          </button>

          <button 
            onClick={() => navigate("/work-area")}
            className="btn-primary gap-2"
          >
            <Plus className="w-5 h-5" />
            <span className="hidden sm:inline">Create New Organization</span>
          </button>
        </div>
      </motion.div>

      {/* Table */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
        className="bg-card rounded-xl border border-border overflow-hidden shadow-sm"
      >
        <div className="overflow-x-auto">
          <table className="data-table">
            <thead>
              <tr>
                <th>Organization</th>
                <th>Industry</th>
                <th>Country</th>
                <th>Employees</th>
                <th>Status</th>
                <th>Subscription</th>
                <th className="text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredOrgs.map((org, index) => (
                <motion.tr
                  key={org.id}
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.05 * index }}
                  className="group"
                >
                  <td>
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center">
                        <Building2 className="w-5 h-5 text-primary" />
                      </div>
                      <span className="font-medium text-foreground">{org.name}</span>
                    </div>
                  </td>
                  <td className="text-muted-foreground">{org.industry}</td>
                  <td className="text-muted-foreground">{org.country}</td>
                  <td className="text-muted-foreground">{org.employees.toLocaleString()}</td>
                  <td>
                    <StatusBadge status={org.status} />
                  </td>
                  <td>
                    <span className={`text-sm font-medium ${
                      org.plan === "Premium" ? "text-accent" :
                      org.plan === "Standard" ? "text-primary" : "text-muted-foreground"
                    }`}>
                      {org.plan}
                    </span>
                  </td>
                  <td>
                    <div className="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button 
                        onClick={() => navigate(`/organizations/${org.id}`)}
                        className="p-2 rounded-lg hover:bg-muted transition-colors"
                        title="View"
                      >
                        <Eye className="w-4 h-4 text-muted-foreground" />
                      </button>
                      <button 
                        className="p-2 rounded-lg hover:bg-muted transition-colors"
                        title="Edit"
                      >
                        <Pencil className="w-4 h-4 text-muted-foreground" />
                      </button>
                      <button 
                        onClick={() => navigate(`/setup/${org.id}`)}
                        className="p-2 rounded-lg hover:bg-muted transition-colors"
                        title="Manage"
                      >
                        <Settings className="w-4 h-4 text-muted-foreground" />
                      </button>
                      <button className="p-2 rounded-lg hover:bg-muted transition-colors">
                        <MoreVertical className="w-4 h-4 text-muted-foreground" />
                      </button>
                    </div>
                  </td>
                </motion.tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        <div className="flex items-center justify-between px-6 py-4 border-t border-border">
          <p className="text-sm text-muted-foreground">
            Showing <span className="font-medium text-foreground">{filteredOrgs.length}</span> of{" "}
            <span className="font-medium text-foreground">{organizations.length}</span> organizations
          </p>
          <div className="flex items-center gap-2">
            <button className="p-2 rounded-lg border border-border hover:bg-muted transition-colors disabled:opacity-50" disabled>
              <ChevronLeft className="w-4 h-4" />
            </button>
            <button className="px-3 py-1.5 rounded-lg bg-primary text-primary-foreground text-sm font-medium">
              1
            </button>
            <button className="px-3 py-1.5 rounded-lg hover:bg-muted text-sm text-muted-foreground transition-colors">
              2
            </button>
            <button className="px-3 py-1.5 rounded-lg hover:bg-muted text-sm text-muted-foreground transition-colors">
              3
            </button>
            <button className="p-2 rounded-lg border border-border hover:bg-muted transition-colors">
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </motion.div>
    </DashboardLayout>
  );
}
