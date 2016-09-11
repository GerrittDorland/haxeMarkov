package ;
import js.Node;
import js.node.Http;
import js.node.Path;
import js.npm.Express;
import js.npm.express.*;
import js.npm.Jade;
import haxe.Timer;
import de.polygonal.core.math.random.ParkMiller;
import haxe.Utf8;
class MainIntermediate
{
    var rng : ParkMiller;
    var suffixMap : Map<String, Array<String> >;
    var subStrIndex : Int;
    var key1Delim = "ÿ";
    var key2Delim = "þ";
    var wordDelim = "ý";
    var outputFinal = "";

    function new()
    {
        var app : Express   = new Express();
        rng = new ParkMiller();
        suffixMap = new Map();

        rng.setSeed(Std.int(Date.now().getTime()));
        //sys.io.File.saveContent("fuggle", 'test.txt');
        app.set('port', 3000);
        app.set('view engine', 'jade');
        app.use(new Favicon(Node.__dirname + '/favicon.ico'));

        app.use(BodyParser.urlencoded({extended: true}));
        app.use(BodyParser.json());
        app.use(BodyParser.urlencoded());
        // app.use(new MethodOverride()); // can't find it in js-kit AND don't know what it does...
        app.use(new Static(Path.join(Node.__dirname, 'public')));

        // Routes
        // http://localhost:3000
        app.get('/', function (req, res) {
            res.sendfile(Node.__dirname + '/views/test.html');
        });

        app.post('/index', function (req, res) {
            res.sendfile(Node.__dirname + '/views/test.html');
        });

        app.post('/getOutput', function (req:Request, res:Response) {
            outputMaster();
            res.render('output',{words:outputFinal});
        });

        app.post('/submitted', function(req, res) {
          res.sendfile(Node.__dirname + '/views/test.html');
          var text = req.param('message');
          saveText(text);
          });

        // http://localhost:3000/nope
        app.use(function(req, res, next) {
            res.status(404).send('404');
        });

        app.listen(app.get('port'), function(){
            trace('Express server listening on port ' + app.get('port'));
        });
    }
    static public function main()
    {
        var main = new MainIntermediate();
    }

    public function outputMaster()
    {
      trace("Loading old data...");
      loadMap();

      trace("Generating output...");
      generateOutput();

      trace("Complete!");
    }

    public function generateOutput()
    {
      var key1 : String = "ÿ";
      var key2 : String = "";
      var word : String = "";
      var output : String = "";
      var range : Int = 0;
      var jigoo : Bool = false;

      while(jigoo == false)
      {
        range = suffixMap[key1 + key2].length;
        word = suffixMap[key1 + key2][Std.int(rng.random() % range)];

        key1 = key2 + "ÿ";
        key2 = word;

        //If we have hit a dead end, start over.
        if(suffixMap.get(key1 + key2) == null)
        {
          key1 = "ÿ";
          key2 = "";
        }

        if( Std.int(rng.random() % 1000) < 50)
        {
          jigoo = true;
          output += word + ".";
        }
        else
        {
          output += word + " ";
        }
      }

      trace("Storing final result...");
      outputFinal = output;
    }

    public function saveText(input:String)
    {
      trace("Loading old data...");
      loadMap();
      trace("Finished loading old data.");

      trace("Inputting new data...");
      var newData = input.split(" ");
      storeNewData(newData);

      trace("Saving to database...");
      writeDatabase();

      trace("Clearing map for memory...");
      suffixMap = new Map();

      trace("Complete!");


    }

    public function writeDatabase()
    {
      var content : String = "";

      for( key in suffixMap.keys() )
      {
        content += key + "þ";
        for( i in 0...suffixMap[key].length )
        {
          content += suffixMap[key][i];
          if( i != (suffixMap[key].length - 1))
          {
            content += "ý";
          }
          else
          {
            content += "\n";
          }
        }
      }
      sys.io.File.saveContent( 'database.txt', content );
    }

    public function storeNewData(input:Array<String>)
    {
      var key1 = null;
      var key2 = null;
      var word = null;

      for(i in 0...input.length) //Just to be safe, I guess.
      {
        key1 = key2;
        if(key1 == null)
        {
          key1 = "";
        }
        key1 += "ÿ";

        key2 = word;
        if(key2 == null)
        {
          key2 = "";
        }

        word = input[i];

        //Prevent data loss
        if(suffixMap.get(key1 + key2) != null)
        {
          suffixMap.get(key1 + key2).push(word);
        }
        else
        {
          var holder : Array<String> = [];
          holder.push(word);
          suffixMap.set(key1 + key2, holder);
        }
      }
    }

    public function loadMap()
    {
      var fname = "database.txt";
      var fin = sys.io.File.getContent(fname);
      subStrIndex = 0;

      while(subStrIndex <= fin.length - 5) //Just to be safe, I guess.
      {
        var subString = readLine(fin);
        var sub1 = subString.split(Std.string(key1Delim));
        var key1 = sub1[0] + "ÿ";
        var sub2 = sub1[1].split(Std.string(key2Delim));
        var key2 = sub2[0];
        var sub3 = sub2[1];
        var words = sub3.split(Std.string(wordDelim));

        //Prevent data loss
        if(suffixMap.get(key1 + key2) != null)
        {
          for(i in 0...words.length)
          {
            suffixMap.get(key1 + key2).push(words[i]);
          }
        }
        else
        {
          suffixMap.set(key1 + key2, words);
        }
      }
    }

    public function readLine(data:String):String
    {
      var itStart : Int = subStrIndex;

      while(data.charAt(subStrIndex) != '\n' && data.charAt(subStrIndex) != null)
      {
        subStrIndex ++;
      }
      //Don't increment subStrIndex so we can skip the bullshit
      subStrIndex++;

      return(data.substring(itStart, subStrIndex - 1));
    }
}
