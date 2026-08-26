type AssetStatus "AVAILABLE"|"LOANED_OUT"|"OCCUPIED"|"UNDER_MAINTENANCE"|"DISPOSED";

type ScheduleType "MAINTENANCE"|"BOOKING"|"SERVICING";

type WorkOrderStatus "OPEN"|"IN_PROGRESS"|"CLOSED";

type Component record {|
    string compId;
    string name;
    string description;
|};

type Schedule record {|
    string scheduleId;
    ScheduleType scheduleType;
    string dueDate;
    string description;
|};

type Task record {|
    string taskId;
    string description;
|};

type WorkOrder record {|
    string orderId;
    WorkOrderStatus status;
    string description;
    Task[] tasks;
|};

type Asset record {|
    readonly string assetTag;
    string name;
    string description;
    string institution;
    string site;
    AssetStatus status;
    string dateAcquired;
    Component[] components;
    Schedule[] schedules;
    WorkOrder[] workOrders;
|};

type Institution record {|
    readonly string name;
    string[] sites;
|};
