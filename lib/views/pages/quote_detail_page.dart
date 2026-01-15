import 'dart:io';
import 'dart:typed_data';

import 'package:appinio_social_share/appinio_social_share.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../controllers/favorite_controller.dart';
import '../../models/quote_model.dart';
import '../themes/typography.dart';
import '../widgets/icon_solid_light.dart';

enum SocialShare {
  telegram,
  whatsapp,
  facebook,
  facebook_stories,
  messenger,
  twitter,
  instagram,
  instagramDirect,
  instagram_stories,
  tiktok,
  copyLink,
  system,
}

class QuoteDetailPage extends ConsumerStatefulWidget {
  const QuoteDetailPage({super.key, required this.quote});

  final Quote quote;

  @override
  ConsumerState<QuoteDetailPage> createState() => _QuoteDetailPageState();
}

class _QuoteDetailPageState extends ConsumerState<QuoteDetailPage> {
  Quote get quote => widget.quote;

  final AppinioSocialShare appinioSocialShare = AppinioSocialShare();
  Map<String, bool> installedApps = {};

  final ScreenshotController screenshotController = ScreenshotController();
  final GlobalKey quotCardKey = GlobalKey();
  final GlobalKey iconButtonKey = GlobalKey();

  final pageIndexNotifier = ValueNotifier(0);
  final indexViewNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    appinioSocialShare.getInstalledApps().then((value) {
      installedApps = value.cast<String, bool>();
      setState(() {});
    });
  }

  void onTapFavorite(WidgetRef ref) async {
    await ref.read(favoriteProvider.notifier).toggleFavorite(quote);
  }

  Future<File> _saveImage(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/quote.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> shareQuoteTo(SocialShare type, {Uint8List? memoryImage}) async {
    final text = '${quote.content}\n\n~ ${quote.author}';
    final fbAppID = dotenv.get('FACEBOOK_APP_ID');

    String? path;
    if (memoryImage != null) {
      path = (await _saveImage(memoryImage)).path;
    }

    switch (type) {
      case SocialShare.telegram:
        appinioSocialShare.android.shareToTelegram(text, path);
        break;
      case SocialShare.whatsapp:
        appinioSocialShare.android.shareToWhatsapp(text, path);
        break;
      case SocialShare.facebook:
        if (path != null) {
          appinioSocialShare.android.shareToFacebook(text, <String>[path]);
        }
        break;
      case SocialShare.instagram_stories:
        appinioSocialShare.android.shareToInstagramStory(
          fbAppID,
          backgroundImage: path,
        );
        break;
      case SocialShare.facebook_stories:
        appinioSocialShare.android.shareToFacebookStory(
          fbAppID,
          backgroundImage: path,
        );
        break;
      case SocialShare.messenger:
        appinioSocialShare.android.shareToMessenger(text);
        break;
      case SocialShare.twitter:
        appinioSocialShare.android.shareToTwitter(text, path);
        break;
      case SocialShare.instagram:
        if (path != null) {
          appinioSocialShare.android.shareToInstagramFeed(text, path);
        }
        break;
      case SocialShare.instagramDirect:
        appinioSocialShare.android.shareToInstagramDirect(text);
        break;
      case SocialShare.tiktok:
        if (path != null) {
          appinioSocialShare.android.shareToTiktokStatus(<String>[path]);
        }
        break;
      case SocialShare.copyLink:
        appinioSocialShare.android.copyToClipBoard(text);
        break;
      default:
        appinioSocialShare.android.shareToSystem('Share Quote', text, path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteState = ref.watch(favoriteProvider);
    final isFavorite = ref
        .read(favoriteProvider.notifier)
        .isFavorite(quote.content);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconSolidLight(
          icon: PhosphorIcons.caretLeft(PhosphorIconsStyle.regular),
          onTap: () => Navigator.pop(context),
        ),
        title: Text('Quote Detail', style: MyTypography.h3),
      ),
      body: Container(
        key: quotCardKey,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(quote.backgroundColor),
          borderRadius: BorderRadius.circular(36),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Icon(
                PhosphorIcons.quotes(PhosphorIconsStyle.fill),
                size: 70,
                color: Color(quote.textColor),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AutoSizeText(
                  quote.content,
                  maxFontSize: 28,
                  minFontSize: 18,
                  textAlign: quote.textAlign,
                  style: GoogleFonts.getFont(
                    quote.fontFamily,
                    color: Color(quote.textColor),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                quote.author,
                style: MyTypography.body2.copyWith(
                  color: Color(quote.textColor),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  favoriteState.isLoading
                      ? const CircularProgressIndicator()
                      : IconSolidLight(
                          icon: isFavorite
                              ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
                              : PhosphorIcons.heart(PhosphorIconsStyle.regular),
                          onTap: () => onTapFavorite(ref),
                        ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      WoltModalSheet.show(
                        context: context,
                        pageIndexNotifier: pageIndexNotifier,
                        pageListBuilder: (ctx) => [shareQuot(ctx)],
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  WoltModalSheetPage shareQuot(BuildContext context) {
    return WoltModalSheetPage(
      child: Column(
        children: [
          socialButton(SocialShare.whatsapp, 'WhatsApp'),
          socialButton(SocialShare.telegram, 'Telegram'),
          socialButton(SocialShare.twitter, 'Twitter'),
        ],
      ),
    );
  }

  Widget socialButton(SocialShare type, String title) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        shareQuoteTo(type);
      },
    );
  }
}
