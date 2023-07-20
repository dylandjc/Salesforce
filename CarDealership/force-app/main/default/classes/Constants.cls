/**
    @author: Dan Thoreson
    @date: 03-Aug-2022
    @description: Application constant strings and numbers are stored here
                    Reference values like: Constants.MAKES.CADILLAC;
    @test class: ConstantsTest
**/
public class Constants {

    public static final Integer VIN_LENGTH = 17;

    public static final Countries COUNTRIES {get {
        if(COUNTRIES == null) {
            COUNTRIES = new Countries();
        }

        return COUNTRIES;
    } set;}    

    public static final LEAD_STATUSES LEAD_STATUSES {get {
        if(LEAD_STATUSES == null) {
            LEAD_STATUSES = new LEAD_STATUSES();
        }

        return LEAD_STATUSES;
    } set;}    

    public static final Stage_Names STAGE_NAMES {get {
        if(STAGE_NAMES == null) {
            STAGE_NAMES = new Stage_Names();
        }

        return STAGE_NAMES;
    } set;}    

    public static final Makes MAKES {get {
        if(MAKES == null) {
            MAKES = new Makes();
        }

        return MAKES;
    } set;}

    public static final VehicleStatuses VEHICLE_STATUSES {get {
        if(VEHICLE_STATUSES == null) {
            VEHICLE_STATUSES = new VehicleStatuses();
        }

        return VEHICLE_STATUSES;
    } set;}     

    public static final List<String> ALL_MAKES = new List<String>{
        Constants.MAKES.FORD,
        Constants.MAKES.CHEVROLET,
        Constants.MAKES.JEEP,
        Constants.MAKES.CADILLAC,
        Constants.MAKES.LINCOLN,
        Constants.MAKES.LAND_ROVER,
        Constants.MAKES.PORSCHE,
        Constants.MAKES.MINI,
        Constants.MAKES.TOYOTA,
        Constants.MAKES.HONDA
    };

    //public static final List<String> ALL_STATUS = new List<String>{
    //    Constants.VEHICLE_STATUSES.IN_PROGRESS,
    //    Constants.VEHICLE_STATUSES.PENDING,
    //    Constants.VEHICLE_STATUSES.IN_STOCK
    //};

    public static final Map<String, String> COUNTRIES_FOR_MAKES = new Map<String, String>{
        Constants.MAKES.FORD => Constants.COUNTRIES.USA,
        Constants.MAKES.CHEVROLET => Constants.COUNTRIES.USA,
        Constants.MAKES.JEEP => Constants.COUNTRIES.USA,
        Constants.MAKES.CADILLAC => Constants.COUNTRIES.USA,
        Constants.MAKES.LINCOLN => Constants.COUNTRIES.USA,
        Constants.MAKES.LAND_ROVER => Constants.COUNTRIES.UK,
        Constants.MAKES.PORSCHE => Constants.COUNTRIES.GERMANY,
        Constants.MAKES.MINI => Constants.COUNTRIES.UK,
        Constants.MAKES.TOYOTA => Constants.COUNTRIES.JAPAN,
        Constants.MAKES.HONDA => Constants.COUNTRIES.JAPAN
    };


    public static final Models MODELS {get {
        if(MODELS == null) {
            MODELS = new Models();
        }

        return MODELS;
    } set;}

    public static final Map<String, List<String>> MODELS_BY_MAKES = new Map<String, List<String>>{
        Constants.MAKES.FORD => new List<String>{
            Constants.MODELS.MUSTANG,
            Constants.MODELS.EXPLORER,
            Constants.MODELS.F_150
        },
        Constants.MAKES.CHEVROLET => new List<String>{
            Constants.MODELS.TRAILBLAZER,
            Constants.MODELS.CAMARO
        },
        Constants.MAKES.JEEP => new List<String>{
            Constants.MODELS.GRAND_CHEROKEE,
            Constants.MODELS.WRANGLER
        },
        Constants.MAKES.CADILLAC => new List<String>{
            Constants.MODELS.XT4,
            Constants.MODELS.CTS,
            Constants.MODELS.CT5
        },
        Constants.MAKES.LINCOLN => new List<String>{
            Constants.MODELS.NAVIGATOR
        },
        Constants.MAKES.LAND_ROVER => new List<String>{
            Constants.MODELS.RANGE_ROVER,
            Constants.MODELS.RANGE_ROVER_SPORT
        },
        Constants.MAKES.PORSCHE => new List<String>{
            Constants.MODELS.PORSCHE_911
        },
        Constants.MAKES.MINI => new List<String>{
            Constants.MODELS.COOPER,
            Constants.MODELS.COOPER_S
        },
        Constants.MAKES.TOYOTA => new List<String>{
            Constants.MODELS.COROLLA,
            Constants.MODELS.CAMRY
        },
        Constants.MAKES.HONDA => new List<String>{
            Constants.MODELS.PILOT,
            Constants.MODELS.CR_V
        }
    };

    public class Countries {
        public final String USA = 'United States';
        public final String JAPAN = 'Japan';
        public final String GERMANY = 'Germany';
        public final String UK = 'United Kingdom';
    }    

    public class Makes {
        public final String FORD = 'Ford';
        public final String CHEVROLET = 'Chevrolet';
        public final String JEEP = 'Jeep';
        public final String DODGE = 'Dodge';
        public final String CADILLAC = 'Cadillac';
        public final String LINCOLN = 'Lincoln';
        public final String LAND_ROVER = 'Land Rover';
        public final String PORSCHE = 'Porsche';
        public final String MINI = 'Mini';
        public final String TOYOTA = 'Toyota';
        public final String HONDA = 'Honda';
    }

    public class Models {
        public final String MUSTANG = 'Mustang';
        public final String EXPLORER = 'Explorer';
        public final String F_150 = 'F-150';
        public final String TRAILBLAZER = 'Trailblazer';
        public final String CAMARO = 'Camaro';
        public final String GRAND_CHEROKEE = 'Grand Cherokee';
        public final String WRANGLER = 'Wrangler';
        public final String XT4 = 'XT4';
        public final String CTS = 'CTS';
        public final String CT5 = 'CT5';
        public final String NAVIGATOR = 'Navigator';
        public final String RANGE_ROVER = 'Range Rover';
        public final String RANGE_ROVER_SPORT = 'Range Rover Sport';
        public final String PORSCHE_911 = '911';
        public final String COOPER = 'Cooper';
        public final String COOPER_S = 'Cooper S';
        public final String COROLLA = 'Corolla';
        public final String CAMRY = 'Camry';
        public final String PILOT = 'Pilot';
        public final String CR_V = 'CR-V';
    }

    public class VehicleStatuses {
        public final String IN_PROGRESS = 'In Progress';
        public final String PENDING = 'Pending';
        public final String IN_STOCK = 'In Stock';
        public final String SOLD = 'Sold';

    }

    public class LEAD_STATUSES {
        public final String INTAKE = 'Intake';
        public final String CONTACTED = 'Contacted';
        public final String NO_LONGER_BUYING = 'No Longer Buying';
        public final String APPLICATION_STARTED = 'Application Started';
        public final String TEST_DRIVE_SCHEDULED = 'Test Drive Scheduled';
    }

    public class Stage_Names {
        public final String CLOSED_WON = 'Closed Won';
        public final String CLOSED_LOST = 'Closed Lost';
        public final String TEST_DRIVE = 'Test Drive';
        public final String FINANCIAL_VERIFICATION = 'Financial Verification';
        public final String Application_Started = 'Application Started';
        public final String IN_PERSON_INQUIRY = 'In-Person Inquiry';
        public final String PAPERS_SIGNED = 'Papers Signed';
    }

    public static final String OPP_URL = 'https://doordash64-dev-ed.lightning.force.com/lightning/r/Opportunity/';

    //CURRENT ASSUMPTION IS WE HAVE ONE DEALERSHIP AND ALL VEHICLES ARE IN SAID DEALERSHIP--all lot sections are also in the dealership
    

    public static final Map<String, Integer> LOTSPACES = new Map<String, Integer>{
        'A' => 8,
        'B' => 8,
        'C' => 10,
        'D' => 10,
        'E' => 10,
        'F' => 12,
        'G' => 12,
        'H' => 15,
        'I' => 12,
        'J' => 12,
        'K' => 10,
        'L' => 10,
        'M' => 10,
        'N' => 8,
        'O' => 8
    };

    public static final Integer DEALERSHIP_SIZE = 155;

    public static final Map<String, String> API_DRIVE_TYPES = new Map<String,String>{
        'fwd'=>'Front-wheel Drive',
        '4wd'=>'4-wheel Drive',
        'rwd'=>'Rear-wheel Drive',
        'awd'=>'All-wheel Drive'
    };

    public static final List<String> SALES_REPS = new List<String>{
        'Camilla Chang',
        'Casey Serrano',
        'Chana Juarez',
        'Gia Stephenson',
        'Giovani Mitchell',
        'Jermaine Becker',
        'Jordyn Madden',
        'Rayna Reilly',
        'Tiffany Rollins',
        'Yosef Shepherd'	
    };

    public static final Map<String, String> COLOR_HEX_CODES = new Map<String, String>{
        'Green' => '#6a8f6b',
        'Orange'  => '#f28749',
        'Black' =>'#0f1026',
        'Purple' =>'#c596d9',
        'Beige' =>'#d9c0a3',
        'Grey' => '#d5d9d2',
        'Red' => '#f24405',
        'Yellow'  =>'#f2d027',
        'Blue' => '#1b2040',
        'Silver'=>'#BEC2CB',
        'Brown'=>'#481F01',
        'Gold'=>'#D1B000',
        'Gray'=>'#808080',
        'White'=>'#E8E8E8'
    }; 
}