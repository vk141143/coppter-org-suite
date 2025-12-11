import { cn } from "@/lib/utils";

type StatusType = "active" | "trial" | "expired" | "pending";

interface StatusBadgeProps {
  status: StatusType;
  label?: string;
}

const statusConfig = {
  active: { className: "status-active", defaultLabel: "Active" },
  trial: { className: "status-trial", defaultLabel: "Trial" },
  expired: { className: "status-expired", defaultLabel: "Expired" },
  pending: { className: "status-pending", defaultLabel: "Pending" },
};

export function StatusBadge({ status, label }: StatusBadgeProps) {
  const config = statusConfig[status];
  
  return (
    <span className={cn("status-badge", config.className)}>
      <span className={cn(
        "w-1.5 h-1.5 rounded-full mr-1.5",
        status === "active" && "bg-success",
        status === "trial" && "bg-warning",
        status === "expired" && "bg-destructive",
        status === "pending" && "bg-muted-foreground"
      )} />
      {label || config.defaultLabel}
    </span>
  );
}
