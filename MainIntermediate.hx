package ;
import js.Node;
import js.node.Http;
import js.node.Path;
import js.npm.Express;
import js.npm.express.*;
import js.npm.Jade;
import haxe.Timer;
import de.polygonal.core.math.random.ParkMiller;
class MainIntermediate
{
    function new()
    {
        var app : Express   = new Express();
        var rng : ParkMiller = new ParkMiller();

        rng.setSeed(Std.int(Date.now().getTime()));

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
}
