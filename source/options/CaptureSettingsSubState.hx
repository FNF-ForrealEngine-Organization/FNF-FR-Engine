package options;

import flixel.addons.plugin.ScreenShotPlugin;

class CaptureSettingsSubState extends BaseOptionsMenu
{
    public function new() {
        title = Language.getPhrase('capture_menu', 'Capture Settings');
        rpcTitle = "Capture Settings Menu";

        var option:Option = new Option('Enable Capture',
			'If unchecked, will not able to use capture.',
			'enableCapture',
			BOOL);
		addOption(option);

        var option:Option = new Option('Save Format Type',
            'Default is PNG, JPEG or whatever idk put here.',
            'saveFormat',
            STRING,
            ['PNG', 'JPEG']);
        option.onChange = onSaveFormatType;
        addOption(option);

		var option:Option = new Option('JPEG Quality',
			'Changes how quality the JPEG images will\nWork only on JPEG images type only!.',
			'ratingOffset',
			INT);
		option.displayFormat = '%v';
		option.scrollSpeed = 10;
		option.minValue = -80;
		option.maxValue = 100;
        option.onChange = onChangeJPEGQuality;
		addOption(option);

        super();
    }

    function onSaveFormatType()
        ScreenShotPlugin.saveFormat = Reflect.getProperty(CustomFileFormatOption, ClientPrefs.data.saveFormat.toUpperCase());

    function onChangeJPEGQuality()
        ScreenShotPlugin.jpegQuality = ClientPrefs.data.jpegQuality;
}

class CustomFileFormatOption {
    public static var PNG:FileFormatOption = PNG;
    public static var JPEG:FileFormatOption = JPEG;
}