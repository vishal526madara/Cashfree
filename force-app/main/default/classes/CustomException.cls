/**
 * @description       :
 * @author            : Saurav Kashyap
 * @group             :
 * @last modified on  : 11-30-2022
 **/
public class CustomException extends Exception {
  String ERROR_MESSAGE;
  public override String getMessage() {
    return 'Not able to post to Timeline.getting response from Api : ' +
      ERROR_MESSAGE;
  }
}
