import 'package:flutter/material.dart';
import 'package:radiology/controllers/bookmark_controller.dart';
import 'package:radiology/controllers/spotters_controller.dart';
import 'package:radiology/data/repo/spotters_repo.dart';
import 'package:radiology/features/screens/custom_appbar.dart';
import 'package:get/get.dart';
import 'package:radiology/features/screens/osce/osce_content_component/osce_component_widget.dart';
import 'package:radiology/features/screens/spotters/components/spotters_content_section.dart';
import 'package:radiology/features/widgets/bookmart_button.dart';
import 'package:radiology/features/widgets/custom_loading_widget.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:radiology/features/widgets/custom_network_image_widget.dart';
import 'package:radiology/features/widgets/empty_data_widget.dart';
import 'package:radiology/utils/app_constants.dart';
import 'package:radiology/utils/dimensions.dart';
import 'package:radiology/utils/images.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:loop_page_view/loop_page_view.dart';

class SavedOsceScreen extends StatelessWidget {
  SavedOsceScreen({super.key});

  final SpottersRepo noteRepo = Get.put(SpottersRepo(apiClient: Get.find()));
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<BookmarkController>().getSavedOscePaginatedList('1');
    });
    Get.find<SpottersController>().setOffset(1);

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          Get.find<BookmarkController>().savedOsceList != null &&
          !Get.find<BookmarkController>().isSavedOsceLoading) {
        if (Get.find<BookmarkController>().offset < 10) {
          print(
              "print ===========> offset before ${Get.find<BookmarkController>().offset}");
          Get.find<BookmarkController>()
              .setOffset(Get.find<BookmarkController>().offset + 1);
          Get.find<BookmarkController>().showSavedBottomLoader();
          Get.find<BookmarkController>().getSavedOscePaginatedList(
            Get.find<BookmarkController>().offset.toString(),
          );
        }
      }
    });

    return GetBuilder<BookmarkController>(builder: (spottersControl) {
      final list = spottersControl.savedOsceList;
      final isListEmpty = list == null || list.isEmpty;
      return Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        // bottomNavigationBar: SingleChildScrollView(
        //   child: Padding(
        //     padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        //     child: Column(
        //       children: [
        //         isListEmpty && !spottersControl.isSavedSpottersLoading
        //             ? const SizedBox()
        //             : Row(
        //                 mainAxisAlignment: MainAxisAlignment.center,
        //                 children: [
        //                   Text(
        //                     'Slide Right for next ',
        //                     style: poppinsRegular.copyWith(
        //                       fontSize: Dimensions.fontSize14,
        //                       color: Theme.of(context).primaryColor,
        //                     ),
        //                   ),
        //                   Image.asset(
        //                     Images.icdoubleArrowRight,
        //                     height: 18,
        //                   ),
        //                 ],
        //               ),
        //       ],
        //     ),
        //   ),
        // ),
        appBar: const CustomAppBar(
          title: "Saved Osce",
          isBackButtonExist: true,
          backGroundColor: Colors.black,
        ),
        body: Stack(
          children: [
            isListEmpty && !spottersControl.isSavedOsceLoading
                ? Padding(
                    padding:
                        const EdgeInsets.only(top: Dimensions.paddingSize100),
                    child: Center(
                        child: EmptyDataWidget(
                      image: Images.emptyDataBlackImage,
                      fontColor: Theme.of(context).disabledColor,
                      text: 'No Saved OSCE Yet',
                    )),
                  )
                :
                // isListEmpty
                //   ? const Center(child: LoaderWidget()) :
                LoopPageView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: list!.length,
                    itemBuilder: (context, i) {
                      return GetBuilder<BookmarkController>(
                          builder: (bookmarkControl) {
                        bool isBookmarked = bookmarkControl.osceBookmarkIdList
                            .contains(list[i].id);
                       return OsceComponentWidget(
                         imageUrl: '${AppConstants.osceImageUrl}${list[i].image}',
                         title: '${list[i].title}',
                         bookmarkColor: isBookmarked
                             ? Theme.of(context).cardColor
                             : Theme.of(context).cardColor.withOpacity(0.60),
                         onBookmarkTap: () {
                           isBookmarked
                               ? bookmarkControl.removeOsceBookmark(list[i].id)
                               : bookmarkControl.addOsceBookmark('', list[i]);
                         },
                         questionCount: list[i].question?.length ?? 0,
                         questions: list[i].question!.map((q) => q.question.toString()).toList(),
                         answers: list[i].question!.map((q) => q.answer.toString()).toList(),
                         imgClick: () { showImageViewer(
                           context,
                           Image.network(
                             '${AppConstants.spottersImageUrl}${list[i].image}',
                           ).image,
                           swipeDismissible: true,
                           doubleTapZoomable: true,
                         ); },
                       );
                      });
                    },
                  ),
            if (spottersControl.isSavedOsceLoading)
              const Center(child: LoaderWidget()),
          ],
        ),
      );
    });
  }
}
