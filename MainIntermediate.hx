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
            var wordso = "test";
            res.render('output',{words:wordso});
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

    static public function saveText(input:String)
    {
      trace(input);
    }

    static public function loadMap(myMap:Map<String, Array<String> > )
    {
      var fname = "database.txt";
      var fin = sys.io.File.getContent(fname);
      var subStrIndex : Int = 0;
      var key1Delim : Utf8;
      var key2Delim : Utf8;
      var wordDelim : Utf8;
      key1Delim = cast(0xff, Utf8);
      key2Delim = cast(0xfe, Utf8);
      wordDelim = cast(0xfd, Utf8);

      while(subStrIndex <= fin.length - 5) //Just to be safe, I guess.
      {
        var subString = readLine(subStrIndex, fin);
        var key1 = subString.split(cast(key1Delim, String));
        var key2 = subString.split(cast(key2Delim, String));
        var words = subString.split(cast(wordDelim, String));
        myMap.set(key1[0] + key2[0], words);
      }

    }

    static public function readLine(index:Int, data:String):String
    {
      var it : Int = index;
      var itStart : Int = index;

      while(data.charAt(it) != '\n' && data.charAt(it) != null)
      {
        it ++;
        index ++;
      }
      //Don't increment index so we can skip the bullshit
      it --;

      return(data.substring(itStart, it));
    }
}
