import { useState } from "react";
import { DashboardLayout } from "@/components/layout/DashboardLayout";
import { motion, AnimatePresence } from "framer-motion";
import {
  Globe,
  Building2,
  Users,
  Network,
  Plus,
  ChevronRight,
  ChevronDown,
  Pencil,
  Trash2,
  MapPin,
  Briefcase,
  User,
  GitBranch,
  Eye,
  MoreVertical,
} from "lucide-react";
import { StatusBadge } from "@/components/ui/StatusBadge";

type TabType = "geographic" | "functional" | "location" | "employees";

const tabs = [
  { id: "geographic", label: "Geographic Setup", icon: Globe },
  { id: "functional", label: "Functional Divisions", icon: Building2 },
  { id: "location", label: "Location Divisions", icon: MapPin },
  { id: "employees", label: "Employee Management", icon: Users },
];

// Mock data for geographic hierarchy
const geographicData = {
  countries: [
    {
      name: "United States",
      states: [
        {
          name: "California",
          districts: [
            {
              name: "Los Angeles County",
              cities: [
                { name: "Los Angeles", offices: ["HQ - Downtown LA", "Tech Campus - Santa Monica"] },
                { name: "Long Beach", offices: ["Long Beach Office"] },
              ],
            },
            {
              name: "San Francisco County",
              cities: [
                { name: "San Francisco", offices: ["SF Innovation Hub"] },
              ],
            },
          ],
        },
        {
          name: "New York",
          districts: [
            {
              name: "New York City",
              cities: [
                { name: "Manhattan", offices: ["NYC Headquarters", "Wall Street Branch"] },
              ],
            },
          ],
        },
      ],
    },
    {
      name: "United Kingdom",
      states: [
        {
          name: "England",
          districts: [
            {
              name: "Greater London",
              cities: [
                { name: "London", offices: ["London Office - Canary Wharf"] },
              ],
            },
          ],
        },
      ],
    },
  ],
};

// Mock data for functional divisions
const functionalDivisions = [
  { id: "1", name: "Human Resources", head: "Sarah Johnson", subFunctions: ["Recruitment", "Training & Development", "Compensation & Benefits"] },
  { id: "2", name: "Finance", head: "Michael Chen", subFunctions: ["Accounts Payable", "Accounts Receivable", "Financial Planning"] },
  { id: "3", name: "Sales & Marketing", head: "Emily Rodriguez", subFunctions: ["Inside Sales", "Field Sales", "Digital Marketing"] },
  { id: "4", name: "Operations", head: "David Kim", subFunctions: ["Supply Chain", "Quality Assurance", "Logistics"] },
  { id: "5", name: "Technology", head: "Alex Turner", subFunctions: ["Software Development", "IT Infrastructure", "Data Analytics"] },
];

// Mock data for employees
const employees = [
  { id: "EMP001", name: "John Smith", location: "Los Angeles", division: "Technology", functionalHead: "Alex Turner", adminHead: "Sarah Johnson", status: "active" },
  { id: "EMP002", name: "Lisa Wang", location: "San Francisco", division: "Sales", functionalHead: "Emily Rodriguez", adminHead: "David Kim", status: "active" },
  { id: "EMP003", name: "Robert Brown", location: "New York", division: "Finance", functionalHead: "Michael Chen", adminHead: "Sarah Johnson", status: "active" },
  { id: "EMP004", name: "Maria Garcia", location: "London", division: "HR", functionalHead: "Sarah Johnson", adminHead: "David Kim", status: "trial" },
  { id: "EMP005", name: "James Wilson", location: "Los Angeles", division: "Operations", functionalHead: "David Kim", adminHead: "Alex Turner", status: "active" },
];

export default function OrganizationSetup() {
  const [activeTab, setActiveTab] = useState<TabType>("geographic");
  const [expandedItems, setExpandedItems] = useState<string[]>(["United States", "California"]);

  const toggleExpand = (item: string) => {
    setExpandedItems((prev) =>
      prev.includes(item) ? prev.filter((i) => i !== item) : [...prev, item]
    );
  };

  return (
    <DashboardLayout
      title="Organisation Setup"
      subtitle="Configure organizational structure and hierarchy"
    >
      {/* Tabs */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="flex gap-2 mb-6 overflow-x-auto pb-2"
      >
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id as TabType)}
            className={`flex items-center gap-2 px-4 py-2.5 rounded-lg font-medium text-sm whitespace-nowrap transition-all ${
              activeTab === tab.id
                ? "bg-primary text-primary-foreground shadow-md"
                : "bg-card text-muted-foreground hover:bg-muted border border-border"
            }`}
          >
            <tab.icon className="w-4 h-4" />
            {tab.label}
          </button>
        ))}
      </motion.div>

      <AnimatePresence mode="wait">
        {/* Geographic Setup */}
        {activeTab === "geographic" && (
          <motion.div
            key="geographic"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="bg-card rounded-xl border border-border p-6"
          >
            <div className="flex items-center justify-between mb-6">
              <div>
                <h2 className="text-lg font-semibold text-foreground">Geographic Hierarchy</h2>
                <p className="text-sm text-muted-foreground">Manage locations and offices across regions</p>
              </div>
              <div className="flex gap-2">
                <button className="btn-secondary gap-2">
                  <Plus className="w-4 h-4" />
                  Add Country
                </button>
                <button className="btn-primary gap-2">
                  <Plus className="w-4 h-4" />
                  Add Office
                </button>
              </div>
            </div>

            {/* Tree View */}
            <div className="space-y-2">
              {geographicData.countries.map((country) => (
                <div key={country.name} className="border border-border rounded-lg overflow-hidden">
                  <button
                    onClick={() => toggleExpand(country.name)}
                    className="w-full flex items-center justify-between p-4 hover:bg-muted/50 transition-colors"
                  >
                    <div className="flex items-center gap-3">
                      <Globe className="w-5 h-5 text-primary" />
                      <span className="font-medium text-foreground">{country.name}</span>
                      <span className="text-xs text-muted-foreground bg-muted px-2 py-0.5 rounded-full">
                        {country.states.length} states
                      </span>
                    </div>
                    <ChevronDown
                      className={`w-5 h-5 text-muted-foreground transition-transform ${
                        expandedItems.includes(country.name) ? "rotate-180" : ""
                      }`}
                    />
                  </button>

                  <AnimatePresence>
                    {expandedItems.includes(country.name) && (
                      <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: "auto", opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        className="border-t border-border bg-muted/20"
                      >
                        {country.states.map((state) => (
                          <div key={state.name} className="ml-6 border-l-2 border-border">
                            <button
                              onClick={() => toggleExpand(state.name)}
                              className="w-full flex items-center justify-between p-3 hover:bg-muted/50 transition-colors"
                            >
                              <div className="flex items-center gap-3">
                                <MapPin className="w-4 h-4 text-accent" />
                                <span className="text-foreground">{state.name}</span>
                                <span className="text-xs text-muted-foreground bg-muted px-2 py-0.5 rounded-full">
                                  {state.districts.length} districts
                                </span>
                              </div>
                              <ChevronDown
                                className={`w-4 h-4 text-muted-foreground transition-transform ${
                                  expandedItems.includes(state.name) ? "rotate-180" : ""
                                }`}
                              />
                            </button>

                            {expandedItems.includes(state.name) && (
                              <div className="ml-6 border-l-2 border-border/50">
                                {state.districts.map((district) => (
                                  <div key={district.name} className="py-2 px-3">
                                    <p className="text-sm font-medium text-muted-foreground mb-2">
                                      {district.name}
                                    </p>
                                    {district.cities.map((city) => (
                                      <div key={city.name} className="ml-4 mb-2">
                                        <p className="text-sm text-foreground mb-1">{city.name}</p>
                                        <div className="ml-4 space-y-1">
                                          {city.offices.map((office) => (
                                            <div
                                              key={office}
                                              className="flex items-center justify-between p-2 rounded-lg bg-card border border-border/50 group"
                                            >
                                              <div className="flex items-center gap-2">
                                                <Building2 className="w-4 h-4 text-success" />
                                                <span className="text-sm text-foreground">{office}</span>
                                              </div>
                                              <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                                                <button className="p-1 rounded hover:bg-muted">
                                                  <Pencil className="w-3 h-3 text-muted-foreground" />
                                                </button>
                                                <button className="p-1 rounded hover:bg-destructive/10">
                                                  <Trash2 className="w-3 h-3 text-destructive" />
                                                </button>
                                              </div>
                                            </div>
                                          ))}
                                        </div>
                                      </div>
                                    ))}
                                  </div>
                                ))}
                              </div>
                            )}
                          </div>
                        ))}
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>
              ))}
            </div>
          </motion.div>
        )}

        {/* Functional Divisions */}
        {activeTab === "functional" && (
          <motion.div
            key="functional"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="bg-card rounded-xl border border-border p-6"
          >
            <div className="flex items-center justify-between mb-6">
              <div>
                <h2 className="text-lg font-semibold text-foreground">Head Office Functional Divisions</h2>
                <p className="text-sm text-muted-foreground">Define functional departments and their heads</p>
              </div>
              <button className="btn-primary gap-2">
                <Plus className="w-4 h-4" />
                Add Division
              </button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {functionalDivisions.map((division, index) => (
                <motion.div
                  key={division.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.05 }}
                  className="p-4 rounded-xl border border-border hover:border-primary/30 hover:shadow-md transition-all group"
                >
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center">
                        <Briefcase className="w-5 h-5 text-primary" />
                      </div>
                      <div>
                        <h3 className="font-semibold text-foreground">{division.name}</h3>
                        <p className="text-sm text-muted-foreground flex items-center gap-1">
                          <User className="w-3 h-3" />
                          {division.head}
                        </p>
                      </div>
                    </div>
                    <button className="p-1.5 rounded-lg opacity-0 group-hover:opacity-100 hover:bg-muted transition-all">
                      <MoreVertical className="w-4 h-4 text-muted-foreground" />
                    </button>
                  </div>

                  <div className="space-y-1.5">
                    <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">Sub-functions</p>
                    {division.subFunctions.map((sub) => (
                      <div key={sub} className="flex items-center gap-2 text-sm text-foreground">
                        <ChevronRight className="w-3 h-3 text-muted-foreground" />
                        {sub}
                      </div>
                    ))}
                  </div>

                  <div className="flex gap-2 mt-4 pt-4 border-t border-border">
                    <button className="flex-1 btn-ghost text-sm py-1.5">
                      <Pencil className="w-3 h-3 mr-1" />
                      Edit
                    </button>
                    <button className="flex-1 btn-ghost text-sm py-1.5 text-destructive hover:bg-destructive/10">
                      <Trash2 className="w-3 h-3 mr-1" />
                      Remove
                    </button>
                  </div>
                </motion.div>
              ))}
            </div>
          </motion.div>
        )}

        {/* Location Divisions */}
        {activeTab === "location" && (
          <motion.div
            key="location"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="bg-card rounded-xl border border-border p-6"
          >
            <div className="flex items-center justify-between mb-6">
              <div>
                <h2 className="text-lg font-semibold text-foreground">Location Division Mapping</h2>
                <p className="text-sm text-muted-foreground">Map local divisions to head office functions</p>
              </div>
              <div className="flex gap-2">
                <select className="input-field w-48">
                  <option>Select Location</option>
                  <option>Los Angeles - HQ</option>
                  <option>San Francisco</option>
                  <option>New York</option>
                  <option>London</option>
                </select>
                <button className="btn-primary gap-2">
                  <Plus className="w-4 h-4" />
                  Add Mapping
                </button>
              </div>
            </div>

            <div className="overflow-x-auto">
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Local Division</th>
                    <th>HO Functional Division</th>
                    <th>Local Head</th>
                    <th>Employees</th>
                    <th className="text-right">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {[
                    { local: "Local HR", functional: "Human Resources", head: "Jennifer Lee", employees: 12 },
                    { local: "Local Finance", functional: "Finance", head: "Mark Thompson", employees: 8 },
                    { local: "Local Operations", functional: "Operations", head: "Susan Miller", employees: 45 },
                    { local: "Local Sales", functional: "Sales & Marketing", head: "James Brown", employees: 28 },
                    { local: "Local IT", functional: "Technology", head: "Chris Davis", employees: 15 },
                  ].map((mapping, index) => (
                    <motion.tr
                      key={mapping.local}
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: index * 0.05 }}
                      className="group"
                    >
                      <td>
                        <div className="flex items-center gap-2">
                          <MapPin className="w-4 h-4 text-accent" />
                          <span className="font-medium text-foreground">{mapping.local}</span>
                        </div>
                      </td>
                      <td>
                        <div className="flex items-center gap-2">
                          <GitBranch className="w-4 h-4 text-primary" />
                          <span className="text-muted-foreground">{mapping.functional}</span>
                        </div>
                      </td>
                      <td className="text-muted-foreground">{mapping.head}</td>
                      <td>
                        <span className="text-sm font-medium text-foreground">{mapping.employees}</span>
                      </td>
                      <td>
                        <div className="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                          <button className="p-2 rounded-lg hover:bg-muted">
                            <Pencil className="w-4 h-4 text-muted-foreground" />
                          </button>
                          <button className="p-2 rounded-lg hover:bg-destructive/10">
                            <Trash2 className="w-4 h-4 text-destructive" />
                          </button>
                        </div>
                      </td>
                    </motion.tr>
                  ))}
                </tbody>
              </table>
            </div>
          </motion.div>
        )}

        {/* Employee Management */}
        {activeTab === "employees" && (
          <motion.div
            key="employees"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="bg-card rounded-xl border border-border p-6"
          >
            <div className="flex items-center justify-between mb-6">
              <div>
                <h2 className="text-lg font-semibold text-foreground">Employee Management</h2>
                <p className="text-sm text-muted-foreground">Manage employees and their reporting structure</p>
              </div>
              <div className="flex gap-2">
                <button className="btn-secondary gap-2">
                  <Network className="w-4 h-4" />
                  View Hierarchy
                </button>
                <button className="btn-primary gap-2">
                  <Plus className="w-4 h-4" />
                  Add Employee
                </button>
              </div>
            </div>

            <div className="overflow-x-auto">
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Employee ID</th>
                    <th>Name</th>
                    <th>Location</th>
                    <th>Division</th>
                    <th>Functional Head</th>
                    <th>Admin Head</th>
                    <th>Status</th>
                    <th className="text-right">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {employees.map((emp, index) => (
                    <motion.tr
                      key={emp.id}
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: index * 0.05 }}
                      className="group"
                    >
                      <td className="font-mono text-sm text-muted-foreground">{emp.id}</td>
                      <td>
                        <div className="flex items-center gap-3">
                          <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
                            <User className="w-4 h-4 text-primary" />
                          </div>
                          <span className="font-medium text-foreground">{emp.name}</span>
                        </div>
                      </td>
                      <td className="text-muted-foreground">{emp.location}</td>
                      <td className="text-muted-foreground">{emp.division}</td>
                      <td className="text-muted-foreground">{emp.functionalHead}</td>
                      <td className="text-muted-foreground">{emp.adminHead}</td>
                      <td>
                        <StatusBadge status={emp.status as "active" | "trial"} />
                      </td>
                      <td>
                        <div className="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                          <button className="p-2 rounded-lg hover:bg-muted" title="View">
                            <Eye className="w-4 h-4 text-muted-foreground" />
                          </button>
                          <button className="p-2 rounded-lg hover:bg-muted" title="Edit">
                            <Pencil className="w-4 h-4 text-muted-foreground" />
                          </button>
                          <button className="p-2 rounded-lg hover:bg-muted" title="Assign Reporting">
                            <Network className="w-4 h-4 text-muted-foreground" />
                          </button>
                        </div>
                      </td>
                    </motion.tr>
                  ))}
                </tbody>
              </table>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </DashboardLayout>
  );
}
