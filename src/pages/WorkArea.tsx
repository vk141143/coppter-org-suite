import { useState } from "react";
import { DashboardLayout } from "@/components/layout/DashboardLayout";
import { motion, AnimatePresence } from "framer-motion";
import { useNavigate } from "react-router-dom";
import {
  Building2,
  User,
  Calendar,
  CreditCard,
  Check,
  ChevronRight,
  ChevronLeft,
  ArrowRight,
  Upload,
} from "lucide-react";

type Step = 1 | 2 | 3 | 4;

const steps = [
  { id: 1, title: "Basic Details", icon: Building2 },
  { id: 2, title: "Contact Details", icon: User },
  { id: 3, title: "Trial Period", icon: Calendar },
  { id: 4, title: "Subscription", icon: CreditCard },
];

const industries = [
  "Technology",
  "Finance",
  "Healthcare",
  "Education",
  "Manufacturing",
  "Retail",
  "Energy",
  "Transportation",
  "Other",
];

const countries = ["United States", "United Kingdom", "Germany", "India", "Canada", "Australia", "Japan", "France"];

const subscriptionPlans = [
  {
    id: "trial",
    name: "Free Trial",
    price: "$0",
    period: "14 days",
    features: ["Up to 50 users", "Basic reporting", "Email support", "1 location"],
    recommended: false,
  },
  {
    id: "basic",
    name: "Basic",
    price: "$29",
    period: "per month",
    features: ["Up to 200 users", "Standard reporting", "Email & chat support", "5 locations"],
    recommended: false,
  },
  {
    id: "standard",
    name: "Standard",
    price: "$79",
    period: "per month",
    features: ["Up to 1000 users", "Advanced analytics", "Priority support", "Unlimited locations", "API access"],
    recommended: true,
  },
  {
    id: "premium",
    name: "Premium",
    price: "$199",
    period: "per month",
    features: ["Unlimited users", "Custom reporting", "24/7 dedicated support", "Unlimited locations", "Full API access", "Custom integrations"],
    recommended: false,
  },
];

export default function WorkArea() {
  const [currentStep, setCurrentStep] = useState<Step>(1);
  const [selectedPlan, setSelectedPlan] = useState("standard");
  const [trialEnabled, setTrialEnabled] = useState(true);
  const navigate = useNavigate();

  const nextStep = () => {
    if (currentStep < 4) {
      setCurrentStep((prev) => (prev + 1) as Step);
    }
  };

  const prevStep = () => {
    if (currentStep > 1) {
      setCurrentStep((prev) => (prev - 1) as Step);
    }
  };

  const handleSubmit = () => {
    navigate("/organizations");
  };

  return (
    <DashboardLayout
      title="Work Area"
      subtitle="Onboard a new organization to the platform"
    >
      {/* Progress Steps */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-card rounded-xl border border-border p-6 mb-8"
      >
        <div className="flex items-center justify-between">
          {steps.map((step, index) => (
            <div key={step.id} className="flex items-center">
              <div className="wizard-step">
                <div
                  className={`wizard-step-circle ${
                    currentStep > step.id
                      ? "wizard-step-completed"
                      : currentStep === step.id
                      ? "wizard-step-active"
                      : "wizard-step-pending"
                  }`}
                >
                  {currentStep > step.id ? (
                    <Check className="w-5 h-5" />
                  ) : (
                    <step.icon className="w-5 h-5" />
                  )}
                </div>
                <div className="hidden md:block ml-3">
                  <p
                    className={`text-sm font-medium ${
                      currentStep >= step.id ? "text-foreground" : "text-muted-foreground"
                    }`}
                  >
                    {step.title}
                  </p>
                  <p className="text-xs text-muted-foreground">Step {step.id}</p>
                </div>
              </div>
              {index < steps.length - 1 && (
                <div
                  className={`hidden sm:block w-12 lg:w-24 h-0.5 mx-2 lg:mx-4 ${
                    currentStep > step.id ? "bg-success" : "bg-border"
                  }`}
                />
              )}
            </div>
          ))}
        </div>
      </motion.div>

      {/* Form Content */}
      <AnimatePresence mode="wait">
        <motion.div
          key={currentStep}
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: -20 }}
          transition={{ duration: 0.3 }}
          className="bg-card rounded-xl border border-border p-8"
        >
          {/* Step 1: Basic Details */}
          {currentStep === 1 && (
            <div className="space-y-6">
              <div>
                <h2 className="text-xl font-semibold text-foreground mb-2">Basic Details</h2>
                <p className="text-muted-foreground">Enter the organization's primary information</p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">Organization Name *</label>
                  <input type="text" placeholder="Enter organization name" className="input-field" />
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">Industry *</label>
                  <select className="input-field">
                    <option value="">Select industry</option>
                    {industries.map((ind) => (
                      <option key={ind} value={ind}>{ind}</option>
                    ))}
                  </select>
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">Country *</label>
                  <select className="input-field">
                    <option value="">Select country</option>
                    {countries.map((country) => (
                      <option key={country} value={country}>{country}</option>
                    ))}
                  </select>
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">State</label>
                  <select className="input-field">
                    <option value="">Select state</option>
                  </select>
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">District</label>
                  <select className="input-field">
                    <option value="">Select district</option>
                  </select>
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">City</label>
                  <select className="input-field">
                    <option value="">Select city</option>
                  </select>
                </div>

                <div className="md:col-span-2 space-y-2">
                  <label className="text-sm font-medium text-foreground">HQ Address *</label>
                  <textarea 
                    placeholder="Enter headquarters address" 
                    className="input-field min-h-[100px] resize-none"
                  />
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">Organization Size *</label>
                  <select className="input-field">
                    <option value="">Select size</option>
                    <option value="1-50">1-50 employees</option>
                    <option value="51-200">51-200 employees</option>
                    <option value="201-500">201-500 employees</option>
                    <option value="501-1000">501-1000 employees</option>
                    <option value="1000+">1000+ employees</option>
                  </select>
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">Registration Number</label>
                  <input type="text" placeholder="Optional" className="input-field" />
                </div>
              </div>
            </div>
          )}

          {/* Step 2: Contact Details */}
          {currentStep === 2 && (
            <div className="space-y-6">
              <div>
                <h2 className="text-xl font-semibold text-foreground mb-2">Contact Details</h2>
                <p className="text-muted-foreground">Primary and billing contact information</p>
              </div>

              <div className="space-y-8">
                {/* Primary Contact */}
                <div>
                  <h3 className="text-lg font-medium text-foreground mb-4">Primary Contact</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-foreground">Contact Person *</label>
                      <input type="text" placeholder="Full name" className="input-field" />
                    </div>

                    <div className="space-y-2">
                      <label className="text-sm font-medium text-foreground">Designation *</label>
                      <input type="text" placeholder="e.g. HR Director" className="input-field" />
                    </div>

                    <div className="space-y-2">
                      <label className="text-sm font-medium text-foreground">Mobile Number *</label>
                      <input type="tel" placeholder="+1 (555) 000-0000" className="input-field" />
                    </div>

                    <div className="space-y-2">
                      <label className="text-sm font-medium text-foreground">Email Address *</label>
                      <input type="email" placeholder="email@company.com" className="input-field" />
                    </div>
                  </div>
                </div>

                {/* Billing Contact */}
                <div>
                  <h3 className="text-lg font-medium text-foreground mb-4">Billing Contact</h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-foreground">Billing Contact Name</label>
                      <input type="text" placeholder="Full name" className="input-field" />
                    </div>

                    <div className="space-y-2">
                      <label className="text-sm font-medium text-foreground">Billing Email</label>
                      <input type="email" placeholder="billing@company.com" className="input-field" />
                    </div>

                    <div className="md:col-span-2 space-y-2">
                      <label className="text-sm font-medium text-foreground">Billing Address</label>
                      <textarea 
                        placeholder="Enter billing address" 
                        className="input-field min-h-[100px] resize-none"
                      />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Step 3: Trial Period */}
          {currentStep === 3 && (
            <div className="space-y-6">
              <div>
                <h2 className="text-xl font-semibold text-foreground mb-2">Trial Period Configuration</h2>
                <p className="text-muted-foreground">Set up the trial period for this organization</p>
              </div>

              <div className="space-y-6">
                {/* Enable Trial Toggle */}
                <div className="flex items-center justify-between p-4 rounded-lg bg-muted/50 border border-border">
                  <div>
                    <p className="font-medium text-foreground">Enable Trial Period</p>
                    <p className="text-sm text-muted-foreground">Allow organization to try before subscribing</p>
                  </div>
                  <button
                    onClick={() => setTrialEnabled(!trialEnabled)}
                    className={`relative w-14 h-7 rounded-full transition-colors ${
                      trialEnabled ? "bg-primary" : "bg-muted"
                    }`}
                  >
                    <span
                      className={`absolute top-1 left-1 w-5 h-5 rounded-full bg-card shadow-md transition-transform ${
                        trialEnabled ? "translate-x-7" : "translate-x-0"
                      }`}
                    />
                  </button>
                </div>

                {trialEnabled && (
                  <motion.div
                    initial={{ opacity: 0, height: 0 }}
                    animate={{ opacity: 1, height: "auto" }}
                    exit={{ opacity: 0, height: 0 }}
                    className="grid grid-cols-1 md:grid-cols-2 gap-6"
                  >
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-foreground">Trial Start Date *</label>
                      <input type="date" className="input-field" defaultValue={new Date().toISOString().split('T')[0]} />
                    </div>

                    <div className="space-y-2">
                      <label className="text-sm font-medium text-foreground">Number of Trial Days *</label>
                      <select className="input-field" defaultValue="14">
                        <option value="7">7 days</option>
                        <option value="14">14 days</option>
                        <option value="30">30 days</option>
                        <option value="60">60 days</option>
                      </select>
                    </div>

                    <div className="space-y-2">
                      <label className="text-sm font-medium text-foreground">Trial Expiry Date</label>
                      <input 
                        type="text" 
                        className="input-field bg-muted" 
                        value="Auto-calculated" 
                        disabled 
                      />
                    </div>

                    <div className="space-y-2">
                      <label className="text-sm font-medium text-foreground">Reminder Settings</label>
                      <select className="input-field">
                        <option value="3">3 days before expiry</option>
                        <option value="7">7 days before expiry</option>
                        <option value="both">3 and 7 days before</option>
                      </select>
                    </div>
                  </motion.div>
                )}

                {/* Info Box */}
                <div className="p-4 rounded-lg bg-info/10 border border-info/20">
                  <p className="text-sm text-info">
                    <strong>Note:</strong> Trial organizations have access to all features but limited user capacity. 
                    They will receive automated reminder emails before the trial expires.
                  </p>
                </div>
              </div>
            </div>
          )}

          {/* Step 4: Subscription */}
          {currentStep === 4 && (
            <div className="space-y-6">
              <div>
                <h2 className="text-xl font-semibold text-foreground mb-2">Subscription Setup</h2>
                <p className="text-muted-foreground">Choose a subscription plan for the organization</p>
              </div>

              {/* Plan Cards */}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                {subscriptionPlans.map((plan) => (
                  <motion.button
                    key={plan.id}
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                    onClick={() => setSelectedPlan(plan.id)}
                    className={`subscription-card text-left relative ${
                      plan.recommended ? "subscription-card-featured" : ""
                    } ${
                      selectedPlan === plan.id ? "border-primary ring-2 ring-primary/20" : ""
                    }`}
                  >
                    {plan.recommended && (
                      <span className="absolute -top-3 left-1/2 -translate-x-1/2 px-3 py-1 rounded-full bg-primary text-primary-foreground text-xs font-medium">
                        Recommended
                      </span>
                    )}
                    <div className="space-y-4">
                      <div>
                        <h3 className="text-lg font-semibold text-foreground">{plan.name}</h3>
                        <div className="flex items-baseline gap-1 mt-1">
                          <span className="text-2xl font-bold text-foreground">{plan.price}</span>
                          <span className="text-sm text-muted-foreground">/{plan.period}</span>
                        </div>
                      </div>
                      <ul className="space-y-2">
                        {plan.features.map((feature) => (
                          <li key={feature} className="flex items-start gap-2 text-sm text-muted-foreground">
                            <Check className="w-4 h-4 text-success mt-0.5 flex-shrink-0" />
                            {feature}
                          </li>
                        ))}
                      </ul>
                    </div>
                    {selectedPlan === plan.id && (
                      <motion.div
                        layoutId="selectedPlan"
                        className="absolute inset-0 border-2 border-primary rounded-2xl"
                      />
                    )}
                  </motion.button>
                ))}
              </div>

              {/* Additional Settings */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 pt-6 border-t border-border">
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">Payment Method</label>
                  <select className="input-field">
                    <option value="card">Credit/Debit Card</option>
                    <option value="bank">Bank Transfer</option>
                    <option value="invoice">Invoice</option>
                  </select>
                </div>

                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">Invoice Frequency</label>
                  <select className="input-field">
                    <option value="monthly">Monthly</option>
                    <option value="quarterly">Quarterly</option>
                    <option value="annually">Annually (10% discount)</option>
                  </select>
                </div>
              </div>
            </div>
          )}

          {/* Navigation Buttons */}
          <div className="flex items-center justify-between mt-8 pt-6 border-t border-border">
            <button
              onClick={prevStep}
              disabled={currentStep === 1}
              className="btn-secondary gap-2 disabled:opacity-50"
            >
              <ChevronLeft className="w-4 h-4" />
              Previous
            </button>

            {currentStep < 4 ? (
              <button onClick={nextStep} className="btn-primary gap-2">
                Next Step
                <ChevronRight className="w-4 h-4" />
              </button>
            ) : (
              <button onClick={handleSubmit} className="btn-primary gap-2">
                Create Organization
                <ArrowRight className="w-4 h-4" />
              </button>
            )}
          </div>
        </motion.div>
      </AnimatePresence>
    </DashboardLayout>
  );
}
